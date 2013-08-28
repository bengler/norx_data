ALTER TABLE "n50_arealdekkeflate"
	DROP CONSTRAINT "enforce_srid_geometri";

ALTER TABLE n50_arealdekkeflate
	ALTER COLUMN geometri
	TYPE Geometry(Polygon, 4326)
	USING ST_Transform(geometri, 4326);

ALTER TABLE n50_arealdekkeflate
	ADD CONSTRAINT enforce_srid_geometri CHECK (st_srid(geometri) = 4326);
