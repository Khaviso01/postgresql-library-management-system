# Library Database with PostgreSQL

A relational database project that manages a library's **books**, **authors**, and **patrons** using PostgreSQL. It covers table design, foreign keys, array columns, CRUD operations, and advanced queries, all runnable in **pgAdmin** or **psql**.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Database Schema](#database-schema)
4. [Sample Data](#sample-data)
5. [Sprint 3: Read Operations](#sprint-3-read-operations)
6. [Sprint 4: Update Operations](#sprint-4-update-operations)
7. [Sprint 5: Delete Operations](#sprint-5-delete-operations)
8. [Sprint 6: Advanced Queries](#sprint-6-advanced-queries)
9. [Running in pgAdmin](#running-in-pgadmin)
10. [Running in psql](#running-in-psql)
11. [Design Notes and Known Limitations](#design-notes-and-known-limitations)
12. [Troubleshooting](#troubleshooting)

---

## Project Overview

The library needs to track:

| Entity      | What is tracked                                                      |
|-------------|------------------------------------------------------------------------|
| **Authors** | Name, nationality, birth year, death year                              |
| **Books**   | Title, author, genres, published year, availability                    |
| **Patrons** | Name, email, and the IDs of the books they currently have borrowed     |

A librarian can add books and authors, patrons can borrow and return books, and the librarian can search the catalog or remove outdated records.

---

## Prerequisites

- PostgreSQL 12 or newer
- **pgAdmin 4** *or* the **psql** command-line client
- A database created for this project (e.g. `librarydb`), connected to before running any of the SQL below

---

## Database Schema

Tables are created in this order because `books` references `authors`:

```sql
-- Create authors table
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    nationality VARCHAR(100),
    birth_year INT,
    death_year INT
);

-- Create books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author_id INT REFERENCES authors(id) ON DELETE CASCADE,
    genres TEXT[],
    published_year INT,
    available BOOLEAN DEFAULT TRUE
);

-- Create patrons table
CREATE TABLE patrons (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    borrowed_books INT[]
);
```

**Column notes**

| Column                   | Purpose                                                                 |
|--------------------------|---------------------------------------------------------------------------|
| `authors.id`, `books.id` | `SERIAL` — auto-generated, so PostgreSQL can assign IDs for new rows      |
| `patrons.id`             | Plain `INT` — **not** auto-generated, so every new patron needs an explicit ID (see [Design Notes](#design-notes-and-known-limitations)) |
| `books.author_id`        | Foreign key to `authors.id`                                              |
| `ON DELETE CASCADE`      | Deleting an author also deletes that author's books                      |
| `books.genres`           | `TEXT[]` lets one book have several genres                               |
| `patrons.borrowed_books` | `INT[]` of book IDs the patron currently holds                           |

Verify the tables exist:

```sql
\dt          -- psql only
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
```

---

## Sample Data

Authors are inserted first, then books (which depend on `author_id`), then patrons.

### Authors

```sql
INSERT INTO authors (id, name, nationality, birth_year, death_year) VALUES
(1, 'George Orwell', 'British', 1903, 1950),
(2, 'Harper Lee', 'American', 1926, 2016),
(3, 'F. Scott Fitzgerald', 'American', 1896, 1940),
(4, 'Aldous Huxley', 'British', 1894, 1963),
(5, 'J.D. Salinger', 'American', 1919, 2010),
(6, 'Herman Melville', 'American', 1819, 1891),
(7, 'Jane Austen', 'British', 1775, 1817),
(8, 'Leo Tolstoy', 'Russian', 1828, 1910),
(9, 'Fyodor Dostoevsky', 'Russian', 1821, 1881),
(10, 'J.R.R. Tolkien', 'British', 1892, 1973);
```

### Books

```sql
INSERT INTO books (id, title, author_id, genres, published_year, available) VALUES
(1, '1984', 1, ARRAY['Dystopian', 'Political Fiction'], 1949, TRUE),
(2, 'To Kill a Mockingbird', 2, ARRAY['Southern Gothic', 'Bildungsroman'], 1960, TRUE),
(3, 'The Great Gatsby', 3, ARRAY['Tragedy'], 1925, TRUE),
(4, 'Brave New World', 4, ARRAY['Dystopian', 'Science Fiction'], 1932, TRUE),
(5, 'The Catcher in the Rye', 5, ARRAY['Realist Novel', 'Bildungsroman'], 1951, TRUE),
(6, 'Moby-Dick', 6, ARRAY['Adventure Fiction'], 1851, TRUE),
(7, 'Pride and Prejudice', 7, ARRAY['Romantic Novel'], 1813, TRUE),
(8, 'War and Peace', 8, ARRAY['Historical Novel'], 1869, TRUE),
(9, 'Crime and Punishment', 9, ARRAY['Philosophical Novel'], 1866, TRUE),
(10, 'The Hobbit', 10, ARRAY['Fantasy'], 1937, TRUE);
```

### Patrons

```sql
INSERT INTO patrons (id, name, email, borrowed_books) VALUES
(1, 'Alice Johnson', 'alice@example.com', ARRAY[]::INT[]),
(2, 'Bob Smith', 'bob@example.com', ARRAY[1, 2]),
(3, 'Carol White', 'carol@example.com', ARRAY[]::INT[]),
(4, 'David Brown', 'david@example.com', ARRAY[3]),
(5, 'Eve Davis', 'eve@example.com', ARRAY[]::INT[]),
(6, 'Frank Moore', 'frank@example.com', ARRAY[4, 5]),
(7, 'Grace Miller', 'grace@example.com', ARRAY[]::INT[]),
(8, 'Hank Wilson', 'hank@example.com', ARRAY[6]),
(9, 'Ivy Taylor', 'ivy@example.com', ARRAY[]::INT[]),
(10, 'Jack Anderson', 'jack@example.com', ARRAY[7, 8]);
```

> Note: in this sample data, some patrons already hold books (e.g. Bob Smith holds books 1 and 2), but every book above is inserted with `available = TRUE`. The two are not automatically kept in sync — see [Design Notes](#design-notes-and-known-limitations).

---

## Sprint 3: Read Operations

### Get all books

```sql
SELECT * FROM books;
```

### Select a book by title

```sql
SELECT *
FROM books
WHERE title = '1984';
```

### All books by a specific author

```sql
SELECT b.title, a.name
FROM books b
JOIN authors a ON b.author_id = a.id
WHERE a.name = 'George Orwell';
```

### All available books

```sql
SELECT *
FROM books
WHERE available;
```

> `WHERE available` works because `available` is already a `BOOLEAN`; it is equivalent to `WHERE available = TRUE`.

---

## Sprint 4: Update Operations

### Mark a book as borrowed (set `available` to false)

```sql
UPDATE books
SET available = FALSE
WHERE id = 8;
```

### Add a new genre to an existing book

```sql
UPDATE books
SET genres = array_append(genres, 'Adventure')
WHERE id = 10;
```

### Add a borrowed book to a patron's record

```sql
UPDATE patrons
SET borrowed_books = array_append(borrowed_books, 1)
WHERE id = 2;
```

> These two updates (marking a book unavailable, and adding it to a patron's array) are separate statements. If you only run one of them, the book and the patron record will disagree about who has the book. Run them together as a pair whenever you process a real borrow, and see [Design Notes](#design-notes-and-known-limitations) for a way to enforce this automatically.

---

## Sprint 5: Delete Operations

### Delete a book by title

```sql
DELETE
FROM books
WHERE title = 'Moby-Dick';
```

### Delete an author by ID

```sql
DELETE
FROM authors
WHERE id = 3;
```

Because `books.author_id` was created with `ON DELETE CASCADE`, deleting author `3` (F. Scott Fitzgerald) also deletes *The Great Gatsby* automatically. Check what will be removed before running the delete:

```sql
SELECT title FROM books WHERE author_id = 3;
```

> After these two deletes, book id `6` (`Moby-Dick`) no longer exists, but patron id `6` (Frank Moore) does **not** hold it — his `borrowed_books` array is `{4, 5}`, so this particular delete happens not to create a dangling reference. In general, though, deleting a book that *is* currently borrowed will leave its ID behind in a patron's array. See [Design Notes](#design-notes-and-known-limitations).

---

## Sprint 6: Advanced Queries

### Finding books published after 1950

```sql
SELECT *
FROM books
WHERE published_year > 1950;
```

### Finding all American authors

```sql
SELECT *
FROM authors
WHERE nationality = 'American';
```

### Setting all books available

```sql
UPDATE books
SET available = TRUE;
```

### All books available AND published after 1950

```sql
SELECT *
FROM books
WHERE available AND published_year > 1950;
```

### Finding authors whose name contains "George"

```sql
SELECT *
FROM authors
WHERE name ILIKE '%George%';
```

> `ILIKE` is used instead of `LIKE` so the match is case-insensitive (it would still find "george" or "GEORGE").

### Incrementing published year 1869 by 1

```sql
UPDATE books
SET published_year = published_year + 1
WHERE published_year = 1869;
```

This changes *War and Peace* from `1869` to `1870`.

---

## Running in pgAdmin

1. Open **pgAdmin 4** and connect to your server.
2. Expand **Servers → PostgreSQL → Databases**, right-click **Databases → Create → Database…**, and name it (e.g. `librarydb`).
3. Select the new database, then open **Tools → Query Tool** (or `Alt+Shift+Q`).
4. Paste in the schema SQL first (authors, then books, then patrons), and click **Execute/Run** (▶ or `F5`).
5. Paste in the `INSERT` statements, in the same order, and run them.
6. Paste and run any of the queries from Sprints 3–6 as needed.
7. Check the **Data Output** tab for `SELECT` results and the **Messages** tab for row counts and errors.

**Tips**

- Run statements in dependency order: `authors` table → `books` table → `patrons` table → author inserts → book inserts → patron inserts.
- Highlight just one statement and press `F5` to run only that statement instead of the whole script.
- Right-click a table → **View/Edit Data → All Rows** to browse data visually.

## Running in psql

```bash
psql -U postgres
```

```sql
CREATE DATABASE librarydb;
\c librarydb
```

Then paste the SQL directly from each section above, in order, or save it to a `.sql` file and run:

```bash
psql -U postgres -d librarydb -f library.sql
```

**Handy psql meta-commands**

| Command      | What it does                     |
|--------------|-----------------------------------|
| `\l`         | List databases                    |
| `\c dbname`  | Connect to a database             |
| `\dt`        | List tables                       |
| `\d books`   | Describe the `books` table        |
| `\q`         | Quit                               |

---

## Design Notes and Known Limitations

1. **`patrons.id` is a plain `INT`, not `SERIAL`.** Unlike `authors.id` and `books.id`, PostgreSQL will not generate a patron ID automatically. Adding a new patron requires supplying the next ID yourself, e.g.:

   ```sql
   INSERT INTO patrons (id, name, email, borrowed_books)
   VALUES (11, 'Kara Nelson', 'kara@example.com', ARRAY[]::INT[]);
   ```

   To find the next free ID:

   ```sql
   SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM patrons;
   ```

2. **`authors.id` and `books.id` use `SERIAL`, but the sample data inserts explicit IDs (1–10).** This does not advance the underlying sequence, so the *next* auto-generated insert could try to reuse an existing ID and fail with a duplicate key error. Fix this once after loading the sample data:

   ```sql
   SELECT setval(pg_get_serial_sequence('authors', 'id'), (SELECT MAX(id) FROM authors));
   SELECT setval(pg_get_serial_sequence('books', 'id'), (SELECT MAX(id) FROM books));
   ```

   After this, you can insert new authors/books without specifying `id`:

   ```sql
   INSERT INTO authors (name, nationality, birth_year, death_year)
   VALUES ('Mary Shelley', 'British', 1797, 1851);
   ```

3. **`patrons.borrowed_books` is an array, not a foreign key.** PostgreSQL cannot check that the book IDs inside it actually exist in `books`, or that a book isn't "borrowed" by two patrons at once. This means:
   - Deleting a book does **not** remove its ID from any patron's array.
   - Marking a book `available = FALSE` and adding it to a patron's array are two separate, unenforced statements (see the warning in Sprint 4).

   A more robust design replaces `borrowed_books` with a join table:

   ```sql
   CREATE TABLE loans (
       id          SERIAL PRIMARY KEY,
       patron_id   INT NOT NULL REFERENCES patrons(id) ON DELETE CASCADE,
       book_id     INT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
       borrowed_on DATE NOT NULL DEFAULT CURRENT_DATE,
       returned_on DATE
   );
   ```

   This lets PostgreSQL enforce that every loan references a real patron and a real book, and it keeps a history of past loans instead of only the current ones. This is a good stretch goal but is not required by the current schema.

4. **`ON DELETE CASCADE` on `books.author_id` is destructive.** Deleting an author silently deletes every book by that author. Always check first:

   ```sql
   SELECT title FROM books WHERE author_id = <id>;
   ```

5. **Case sensitivity.** `=` and `LIKE` are case-sensitive in PostgreSQL; `ILIKE` (used for the "George" search) is not.

---

## Troubleshooting

| Problem | Likely cause and fix |
|---------|----------------------|
| `duplicate key value violates unique constraint "authors_pkey"` or `"books_pkey"` | The `SERIAL` sequence is behind after inserting explicit IDs. Run the `setval` statements in [Design Note 2](#design-notes-and-known-limitations). |
| `duplicate key value violates unique constraint "patrons_pkey"` | You reused an existing patron ID. `patrons.id` is not auto-generated — check the next free ID first (see [Design Note 1](#design-notes-and-known-limitations)). |
| `insert or update on table "books" violates foreign key constraint "books_author_id_fkey"` | The `author_id` you used does not exist in `authors`. Insert the author first, or check its ID with `SELECT id FROM authors WHERE name = '...'`. |
| `relation "books" does not exist` | You are connected to the wrong database, or the tables haven't been created yet in this session. Check with `SELECT current_database();` and `\dt`. |
| A `SELECT` returns 0 rows unexpectedly | Check spelling/case (`=` is case-sensitive; try `ILIKE`), and confirm the row wasn't removed by an earlier `DELETE` (e.g. *Moby-Dick* and F. Scott Fitzgerald's books, if Sprint 5 has already been run). |
| A patron's `borrowed_books` still lists a book that was deleted | Expected with the current schema — see [Design Note 3](#design-notes-and-known-limitations). Clean it up manually if needed:<br>`UPDATE patrons SET borrowed_books = ARRAY(SELECT b FROM unnest(borrowed_books) AS b WHERE b IN (SELECT id FROM books));` |

---