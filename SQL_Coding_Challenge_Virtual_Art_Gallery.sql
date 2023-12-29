---Coding Challenge SQL -- Virtual Art Gallery - By Saqib Rangrez

--Creating database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Art_Gallery')
    CREATE DATABASE Art_Gallery;
GO

--use Database
USE Art_Gallery;


-- Creating the Artists table
CREATE TABLE Artists (
 ArtistID INT PRIMARY KEY,
 Name VARCHAR(255) NOT NULL,
 Biography TEXT,
 Nationality VARCHAR(100));


 -- Creating the Categories table
CREATE TABLE Categories (
 CategoryID INT PRIMARY KEY,
 Name VARCHAR(100) NOT NULL);


 -- Creating the Artworks table
CREATE TABLE Artworks (
 ArtworkID INT PRIMARY KEY,
 Title VARCHAR(255) NOT NULL,
 ArtistID INT,
 CategoryID INT,
 Year INT,
 Description TEXT,
 ImageURL VARCHAR(255),
 FOREIGN KEY (ArtistID) REFERENCES Artists (ArtistID),
 FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID));


 -- Creating the Exhibitions table
CREATE TABLE Exhibitions (
 ExhibitionID INT PRIMARY KEY,
 Title VARCHAR(255) NOT NULL,
 StartDate DATE,
 EndDate DATE,
 Description TEXT);


 -- Creating a junction table to associate artworks with exhibitions
CREATE TABLE ExhibitionArtworks (
 ExhibitionID INT,
 ArtworkID INT,
 PRIMARY KEY (ExhibitionID, ArtworkID),
 FOREIGN KEY (ExhibitionID) REFERENCES Exhibitions (ExhibitionID),
 FOREIGN KEY (ArtworkID) REFERENCES Artworks (ArtworkID));


 -- Insert sample data into the Artists table
INSERT INTO Artists (ArtistID, Name, Biography, Nationality) VALUES
 (1, 'Pablo Picasso', 'Renowned Spanish painter and sculptor.', 'Spanish'),
 (2, 'Vincent van Gogh', 'Dutch post-impressionist painter.', 'Dutch'),
 (3, 'Leonardo da Vinci', 'Italian polymath of the Renaissance.', 'Italian');


 -- Insert sample data into the Categories table
INSERT INTO Categories (CategoryID, Name) VALUES
 (1, 'Painting'),
 (2, 'Sculpture'),
 (3, 'Photography');


 -- Insert sample data into the Artworks table
INSERT INTO Artworks (ArtworkID, Title, ArtistID, CategoryID, Year, Description, ImageURL) VALUES
 (1, 'Starry Night', 2, 1, 1889, 'A famous painting by Vincent van Gogh.', 'starry_night.jpg'),
 (2, 'Mona Lisa', 3, 1, 1503, 'The iconic portrait by Leonardo da Vinci.', 'mona_lisa.jpg'),
 (3, 'Guernica', 1, 1, 1937, 'Pablo Picasso\''s powerful anti-war mural.', 'guernica.jpg');


 -- Insert sample data into the Exhibitions table
INSERT INTO Exhibitions (ExhibitionID, Title, StartDate, EndDate, Description) VALUES
 (1, 'Modern Art Masterpieces', '2023-01-01', '2023-03-01', 'A collection of modern art masterpieces.'),
 (2, 'Renaissance Art', '2023-04-01', '2023-06-01', 'A showcase of Renaissance art treasures.');


 -- Insert artworks and exhibitions into junction table
INSERT INTO ExhibitionArtworks (ExhibitionID, ArtworkID) VALUES
 (1, 1),
 (1, 2),
 (1, 3),
 (2, 2);
 

 ------------------------------------------------------------------------------------------------------------------------------------

--1. Retrieve the names of all artists along with the number of artworks they have in the gallery, and
--list them in descending order of the number of artworks.
SELECT A.Name AS ArtistName, COUNT(*) AS ArtworkCount
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name
ORDER BY ArtworkCount DESC;

--or
SELECT A.Name as ArtistName, (SELECT COUNT(*) FROM Artworks AW where AW.ArtistID = A.ArtistID) AS ArtworkCount 
FROM Artists A ORDER BY ArtworkCount;


--2. List the titles of artworks created by artists from 'Spanish' and 'Dutch' nationalities, and order
--them by the year in ascending order.
SELECT AW.Title
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
WHERE A.Nationality IN ('Spanish', 'Dutch')
ORDER BY AW.Year;


--3. Find the names of all artists who have artworks in the 'Painting' category, and the number of
--artworks they have in this category.
SELECT A.Name AS ArtistName, COUNT(*) AS ArtworkCount
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
WHERE AW.CategoryID = (SELECT CategoryID FROM Categories WHERE Name = 'Painting')
GROUP BY A.Name;

--or

SELECT A.ArtistID, A.Name AS ArtistName, COUNT(*) AS ArtworkCount
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
JOIN Categories C ON AW.CategoryID = C.CategoryID
WHERE C.Name = 'Painting'
GROUP BY A.ArtistID, A.Name;


--4. List the names of artworks from the 'Modern Art Masterpieces' exhibition, along with their
--artists and categories.
SELECT AW.Title, A.Name AS ArtistName, C.Name AS CategoryName
FROM Artworks AW
JOIN Artists A ON AW.ArtistID = A.ArtistID
JOIN Categories C ON AW.CategoryID = C.CategoryID
JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title = 'Modern Art Masterpieces';


--5. Find the artists who have more than two artworks in the gallery.
SELECT A.Name AS ArtistName
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name
HAVING COUNT(*) > 2;


--6. Find the titles of artworks that were exhibited in both 'Modern Art Masterpieces' and
--'Renaissance Art' exhibitions
SELECT AW.Title
FROM Artworks AW
JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title IN ('Modern Art Masterpieces', 'Renaissance Art')
GROUP BY AW.Title
HAVING COUNT(DISTINCT E.Title) = 2;


--7. Find the total number of artworks in each category
SELECT c.CategoryID,c.Name, COUNT(aw.ArtworkID) AS NumberOfArtworks
FROM Categories c
LEFT JOIN Artworks aw ON c.CategoryID = aw.CategoryID
GROUP BY c.CategoryID,c.Name;


--8. List artists who have more than 3 artworks in the gallery.
SELECT A.Name AS ArtistName
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name
HAVING COUNT(AW.ArtistID) > 3;


--9. Find the artworks created by artists from a specific nationality (e.g., Spanish).
SELECT AW.*
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
WHERE A.Nationality = 'Spanish';


--10. List exhibitions that feature artwork by both Vincent van Gogh and Leonardo da Vinci
SELECT E.Title
FROM Exhibitions E
JOIN ExhibitionArtworks EA ON E.ExhibitionID = EA.ExhibitionID
JOIN Artworks AW ON EA.ArtworkID = AW.ArtworkID
JOIN Artists A ON AW.ArtistID = A.ArtistID
WHERE A.Name IN ('Vincent van Gogh', 'Leonardo da Vinci')
GROUP BY E.Title
HAVING COUNT(DISTINCT A.Name) = 2;



--11. Find all the artworks that have not been included in any exhibition.
SELECT AW.Title
FROM Artworks AW
LEFT JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
WHERE EA.ExhibitionID IS NULL;

--or

SELECT AW.Title
FROM Artworks AW
LEFT JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
WHERE EA.ExhibitionID NOT IN (SELECT EA.ExhibitionID FROM ExhibitionArtworks);


--12. List artists who have created artworks in all available categories.
SELECT A.Name AS ArtistName
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name
HAVING COUNT(DISTINCT AW.CategoryID) = (SELECT COUNT(*) FROM Categories);


--13. List the total number of artworks in each category.
SELECT c.CategoryID,c.Name, COUNT(aw.ArtworkID) AS NumberOfArtworks
FROM Categories c
LEFT JOIN Artworks aw ON c.CategoryID = aw.CategoryID
GROUP BY c.CategoryID,c.Name;


--14. Find the artists who have more than 2 artworks in the gallery.
SELECT A.Name AS ArtistName
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name
HAVING COUNT(AW.ArtworkID) > 2;


--15.List the categories with the average year of artworks they contain, only for categories with more
--than 1 artwork.
SELECT C.Name AS CategoryName, AVG(AW.Year) AS AvgYear
FROM Artworks AW
JOIN Categories C ON AW.CategoryID = C.CategoryID
GROUP BY C.Name
HAVING COUNT(*) > 1;


--16. Find the artworks that were exhibited in the 'Modern Art Masterpieces' exhibition.
SELECT AW.*
FROM Artworks AW
JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title = 'Modern Art Masterpieces';


--17. Find the categories where the average year of artworks is greater than the average year of all
--artworks.
SELECT C.Name AS CategoryName
FROM Artworks AW
JOIN Categories C ON AW.CategoryID = C.CategoryID
GROUP BY C.Name
HAVING AVG(AW.Year) > (SELECT AVG(Year) FROM Artworks);


--18. List the artworks that were not exhibited in any exhibition.
SELECT AW.Title
FROM Artworks AW
LEFT JOIN ExhibitionArtworks EA ON AW.ArtworkID = EA.ArtworkID
WHERE EA.ExhibitionID IS NULL;


--19. Show artists who have artworks in the same category as "Mona Lisa."
SELECT A.Name AS ArtistName, AW.Title
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
WHERE AW.CategoryID = (SELECT CategoryID FROM Artworks WHERE Title = 'Mona Lisa');


--20. List the names of artists and the number of artworks they have in the gallery.
SELECT A.Name AS ArtistName, COUNT(*) AS ArtworkCount
FROM Artists A
JOIN Artworks AW ON A.ArtistID = AW.ArtistID
GROUP BY A.Name;