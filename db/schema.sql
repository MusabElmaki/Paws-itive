-- UTM Paws-itive Database Schema for Sprint 1
CREATE TABLE cats (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    health_status ENUM('Healthy', 'Injured', 'Sick') DEFAULT 'Healthy',
    last_location VARCHAR(100),
    -- e.g., "KDI", "N28"
    description TEXT
);
CREATE TABLE sightings (
    sighting_id INT AUTO_INCREMENT PRIMARY KEY,
    cat_id INT,
    reporter_name VARCHAR(50),
    sighting_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cat_id) REFERENCES cats(cat_id)
);