CREATE OR REPLACE FUNCTION find_nearby_hotels(
    search_location POINT,
    radius_meters FLOAT,
    location_area VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    distance FLOAT,
    name VARCHAR(20),
    description VARCHAR(50),
    address VARCHAR(50),
    hotel_area VARCHAR(20), 
    coordinates POINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id,
        ST_Distance(
            h.coordinates::geometry, 
            search_location::geometry
        ) as distance,
        h.name,
        h.description,
        h.address,
        h.location_area,  
        h.coordinates
    FROM hotels h
    WHERE 
        h.coordinates IS NOT NULL
        AND ST_DWithin(
            h.coordinates::geometry,
            search_location::geometry,
            radius_meters
        )
        AND (location_area IS NULL OR h.location_area = location_area)
    ORDER BY distance;
END;
$$ LANGUAGE plpgsql STABLE;
