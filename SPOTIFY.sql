-- Creating table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM spotify;

-- EXPLORATOPRY DATA ANALYSIS
SELECT COUNT(*) FROM SPOTIFY;
SELECT COUNT(DISTINCT artist) FROM SPOTIFY;
SELECT COUNT(DISTINCT album) FROM SPOTIFY;
SELECT COUNT(DISTINCT album_type) FROM SPOTIFY;
SELECT MAX(views) FROM SPOTIFY;
SELECT MIN(views) FROM SPOTIFY;
SELECT MAX(duration_min) FROM SPOTIFY;
SELECT MIN(duration_min) FROM SPOTIFY;
SELECT * FROM SPOTIFY
WHERE duration_min = 0;
DELETE FROM SPOTIFY
WHERE duration_min = 0; 
SELECT COUNT(*) FROM SPOTIFY;
SELECT DISTINCT most_played_on FROM spotify;

-- DATA ANALYSIS
--Q1) Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

--Q2) List all albums along with their respective artists.
SELECT  
DISTINCT album, artist
FROM spotify;

--Q3) Get the total number of comments for tracks where licensed = TRUE
SELECT
SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true';

--Q4) Find all tracks that belong to the album type single.
SELECT DISTINCT track 
FROM SPOTIFY
WHERE album_type ILIKE 'single';

--Q5) Count the total number of tracks by each artist
SELECT artist,
COUNT(*) AS total_number_of_tracks
FROM SPOTIFY
GROUP BY artist
ORDER BY total_number_of_tracks DESC;

--Q6) Calculate the average danceability of tracks in each album.
SELECT 
album,
AVG(danceability) AS avg_danceability
FROM SPOTIFY
GROUP BY album
ORDER BY avg_danceability DESC;

--Q7) Find the top 5 tracks with the highest energy values.
SELECT
track,
MAX(energy) AS max_energy
FROM spotify
GROUP BY track
ORDER BY max_energy DESC
LIMIT 5;

--Q8) List all tracks along with their views and likes where official_video = TRUE.
SELECT
track,
SUM(views) AS total_views,
SUM(likes) AS total_likes
FROM SPOTIFY
WHERE official_video = 'true'
GROUP BY track
ORDER BY total_likes DESC;

--Q9) For each album, calculate the total views of all associated tracks.
SELECT 
track,
album,
SUM(views) AS total_views
FROM SPOTIFY
GROUP BY track,album
ORDER BY total_views DESC;

--Q10) Retrieve the track names that have been streamed on Spotify more than YouTube.

WITH stream_cte AS(
SELECT
track,
--most_played_on
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS stream_on_youtube,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS stream_on_spotify
FROM SPOTIFY
GROUP BY track) 

SELECT * FROM stream_cte
WHERE stream_on_spotify > stream_on_youtube
AND stream_on_youtube <> 0;

-- Q11) Find the top 3 most-viewed tracks for each artist using window functions.
WITH rank_cte AS(
SELECT 
artist,
track,
SUM(views) AS total_views,
DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC) as rank
FROM SPOTIFY
GROUP BY artist, track
ORDER BY artist, total_views DESC
)
SELECT * FROM rank_cte
WHERE rank<=3;

-- Q12) Write a query to find tracks where the liveness score is above the average.
WITH liveness_avg_cte AS (
SELECT 
track,
AVG(liveness) as avg_liveness
FROM SPOTIFY
GROUP BY track
ORDER BY avg_liveness DESC
)
SELECT
track,
avg_liveness
FROM liveness_avg_cte
WHERE avg_liveness> (SELECT AVG(liveness) FROM SPOTIFY)
ORDER BY avg_liveness;

--Q13) Use a WITH clause to calculate the difference between the
--highest and lowest energy values for tracks in each album.

WITH energy_cte AS(
SELECT 
album,
MAX(energy) as max_energy,
MIN(energy) as min_energy
FROM SPOTIFY
GROUP by album
)
SELECT 
album,
(max_energy - min_energy) as difference_energy
FROM energy_cte
ORDER by difference_energy DESC;

-- Q14) Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
track,
energy_liveness
FROM SPOTIFY
WHERE energy_liveness > 1.2
ORDER BY energy_liveness ASC;

--Q15) Calculate the cumulative sum of likes for tracks ordered 
--by the number of views, using window functions.

SELECT 
    track,
    COALESCE(views,0) AS views,
    COALESCE(likes,0) AS likes,
    SUM(COALESCE(likes,0)) OVER (ORDER BY COALESCE(views,0) DESC) AS cumulative_sum
FROM SPOTIFY
ORDER BY views DESC;

---- THE END ---




