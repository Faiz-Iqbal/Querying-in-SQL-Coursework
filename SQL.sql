#F28DM CW2

#question 1 
SELECT COUNT(*) AS noOfFemaleActors 
FROM imdb_actors
WHERE sex="F";


#question 2 
SELECT imdb_movies.title AS Movie, imdb_runningtimes.time1 AS Length 
FROM imdb_movies 
JOIN imdb_runningtimes ON imdb_movies.movieid = imdb_runningtimes.movieid 
ORDER BY imdb_runningtimes.time1 DESC 
LIMIT 1;


#question 3 
SELECT COUNT(*) AS ComedyFilmsByHarrison FROM imdb_movies2actors AS mov2act
JOIN imdb_movies2directors AS mov2direct ON mov2direct.movieid = mov2act.movieid
JOIN imdb_actors AS Actor ON mov2act.actorid = Actor.actorid
WHERE mov2direct.genre LIKE '%Comedy%' AND Actor.name = 'Ford, Harrison (I)';


#question 4 
SELECT SUBSTRING_INDEX(Writer.name,' ',1) AS surname_familyName
FROM imdb_movies2writers AS Mov2Writer
JOIN imdb_writers AS Writer ON Mov2Writer.writerid = Writer.writerid
GROUP BY Mov2Writer.writerid
ORDER BY COUNT(*) DESC
LIMIT 1;


#question 5 
SELECT SUM(runTime.time1) AS totalRunningTimeScifi 
FROM imdb_runningtimes AS runTime 
INNER JOIN ( SELECT m2d.movieid AS movieId 
            From imdb_movies AS movie 
            INNER JOIN imdb_movies2directors AS m2d 
            ON movie.movieid=m2d.movieid WHERE m2d.genre="Sci-Fi" ) 
a ON runTime.movieid=a.movieid;


#question 6 
SELECT COUNT(imdb_movies2actors.movieid) AS EwanAndRobert 
FROM imdb_movies2actors 
INNER JOIN ( SELECT actorId FROM imdb_actors AS Actor WHERE Actor.name LIKE "%McGregor, Ewan%" ) AS Act1 
INNER JOIN ( SELECT Movie.movieid FROM imdb_movies2actors AS Movie 
            INNER JOIN ( SELECT actorId FROM imdb_actors AS Actor WHERE Actor.name LIKE "%Carlyle, Robert%" ) AS Act1 ON Movie.actorid=Act1.actorid ) AS Act2 
ON imdb_movies2actors.movieid=Act2.movieid 
AND imdb_movies2actors.actorid=Act1.actorid;


#question 7 
SELECT COUNT(*) AS WorkedTogether10orMoreFilms
FROM(
        SELECT CONCAT(Act1.actorid, '-' , Act2.actorid) 
        FROM imdb_actors AS Act1
        JOIN imdb_movies2actors m2a1 ON Act1.actorid = m2a1.actorid
        JOIN imdb_movies2actors m2a2 ON m2a1.movieid = m2a2.movieid AND m2a1.actorid < m2a2.actorid
        JOIN imdb_actors AS Act2 ON m2a2.actorid = Act2.actorid
        GROUP BY CONCAT(Act1.actorid, '-' , Act2.actorid)
        HAVING COUNT(*)>=10

)Result;

#question 8 
SELECT CONCAT((FLOOR(Movies.year / 10) * 10),"-",(FLOOR(Movies.year / 10) * 10 + 9)) AS Decade,
COUNT(Movies.movieid) AS MoviesPerDecade 
FROM imdb_movies AS Movies
WHERE Movies.year>=1960 AND Movies.year<=2009 GROUP BY Decade;

#question 9 
SELECT COUNT(DISTINCT femaleActors.MovieId) AS MoviesWithMoreFemales 
FROM 
(SELECT mov2actor.MovieId AS MovieId,
 COUNT(Actor.actorid) AS females FROM imdb_movies2actors AS mov2actor 
 INNER JOIN imdb_actors AS Actor 
 ON mov2actor.actorid=Actor.actorid 
 WHERE Actor.sex="F" GROUP BY mov2actor.MovieId) femaleActors 
INNER JOIN 
(SELECT mov2actor.MovieId AS MovieId,
 COUNT(Actor.actorid) AS allCount FROM imdb_movies2actors AS mov2actor 
        INNER JOIN imdb_actors AS Actor ON mov2actor.actorid=Actor.actorid GROUP BY mov2actor.MovieId) allActors 
ON femaleActors.MovieId=allActors.MovieId WHERE femaleActors.females>(allActors.allCount-femaleActors.females);

#question 10 
SELECT imdb_movies2directors.genre AS Genre FROM imdb_movies2directors
INNER JOIN imdb_ratings ON imdb_movies2directors.movieid=imdb_ratings.movieid 
WHERE imdb_ratings.votes>=10000 
GROUP BY imdb_movies2directors.genre 
ORDER BY AVG(imdb_ratings.rank) DESC 
LIMIT 1;

#question 11 
SELECT Actor.name AS NameOfActor FROM imdb_movies2actors AS m2a 
INNER JOIN imdb_movies2directors AS m2d 
INNER JOIN imdb_actors AS Actor ON m2a.movieid=m2d.movieid AND Actor.actorid=m2a.actorid 
GROUP BY m2a.actorid 
HAVING COUNT(DISTINCT(m2d.genre))>=10;

#question 12 
SELECT COUNT(DISTINCT(mov2actor.movieid)) AS WroteAndDirected FROM imdb_movies2writers AS mov2wri 
INNER JOIN imdb_movies2directors AS mov2direc 
INNER JOIN imdb_movies2actors AS mov2actor 
INNER JOIN ( SELECT Actor.actorid AS ActorID,
                Director.directorid AS DirectorID,
                Writer.writerid AS WriterId FROM imdb_actors AS Actor 
                INNER JOIN imdb_directors AS Director 
                INNER JOIN imdb_writers AS Writer ON Actor.name=Director.name AND Actor.name=Writer.name)sub 
ON mov2wri.writerid=sub.WriterId 
AND mov2actor.actorid=sub.ActorID 
AND mov2direc.directorid=sub.DirectorID 
AND mov2wri.movieid=mov2actor.movieid 
AND mov2direc.movieid=mov2actor.movieid;

#question 13 
SELECT (FLOOR(Movie.year / 10) * 10) AS Year_HighestRankedMovie 
FROM imdb_movies AS Movie 
INNER JOIN imdb_ratings AS Rating ON Movie.movieid=Rating.movieid 
GROUP BY CONCAT((FLOOR(Movie.year / 10) * 10),"-",(FLOOR(Movie.year / 10) * 10)+9) 
ORDER BY AVG(Rating.rank) Desc 
LIMIT 1;


#question 14 
SELECT COUNT(DISTINCT movieID) AS Genre_is_NULL 
FROM imdb_movies2directors 
WHERE genre IS NULL;

#question 15 
SELECT COUNT(DISTINCT Mov2Writer.movieid) AS No_Of_Actors
FROM imdb_actors AS Actor1
INNER JOIN imdb_writers AS Writer ON Actor1.name=Writer.name
INNER JOIN imdb_directors AS Director ON Writer.name=Director.name
INNER JOIN imdb_movies2writers AS Mov2Writer ON Mov2Writer.writerid=Writer.writerid
INNER JOIN imdb_movies2directors AS mov2direct ON mov2direct.directorid=Director.directorid AND Mov2Writer.movieid=mov2direct.movieid
LEFT JOIN imdb_movies2actors AS mov2act ON mov2act.movieid=Mov2Writer.movieid AND mov2act.actorid=Actor1.actorid
WHERE mov2act.actorid IS NULL;
