--LIBRARY DATABASE WITH POSTGRESQL

--Create author table
CREATE TABLE authors (
 id SERIAL PRIMARY KEY,
 name VARCHAR(150) NOT NULL,
 nationality VARCHAR(100),
 birth_year INT,
 death_year INT
);

--Create books table
CREATE TABLE books (
id SERIAL PRIMARY KEY,
title VARCHAR(150) NOT NULL,
author_id INT REFERENCES authors(id) ON DELETE CASCADE,
genres TEXT[],
published_year INT,
available BOOLEAN DEFAULT TRUE
);

--Create patron table
CREATE TABLE patrons (
id INT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
borrowed_books INT[]
);


--Insert into authors table
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


-- Insert into books table
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


--insert into patrons table
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


--Get all books
SELECT * FROM books;

--Select a book by title
SELECT *
FROM books
WHERE title = '1984'

--All books by specific author
SELECT b.title, a.name
FROM books b
JOIN authors a ON b.author_id = a.id
WHERE a.name = 'George Orwell';

--All books available
SELECT *
FROM books
WHERE available;


--Sprint 4: Update Operations

--Marking book as borrowed the set availbale as false
UPDATE books
SET available = FALSE
WHERE id = 8;

--Adding new genre to existing book
UPDATE books
SET genres = array_append(genres, 'Adventure')
WHERE id = 10;

--Adding a borrowed book to a patron's record
UPDATE patrons
SET borrowed_books = array_append(borrowed_books, 1)
WHERE id = 2;

-- Sprint 5: Delete Operations

-- Delete a book by title
DELETE
FROM books
WHERE title = 'Moby-Dick';

-- Deleting an author by ID
DELETE 
FROM authors 
WHERE id = 3;

-- Sprint 6: Advanced queries

-- Finding books published after 1950
SELECT *
FROM books
WHERE published_year > 1950;

--Finding all american authors
SELECT *
FROM authors
WHERE nationality = 'American';

--Setting all books available
UPDATE books
SET available = TRUE;

--All books available AND published after 1950
SELECT *
FROM books
WHERE available AND published_year > 1950;

--Finding authors whose name contain "George"
SELECT *
FROM authors
WHERE name ILIKE '%George%';

--Incrementing published year 1869 by 1
UPDATE books
SET published_year = published_year + 1
WHERE published_year = 1869;