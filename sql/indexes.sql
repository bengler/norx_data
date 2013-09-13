CREATE INDEX idx_SSR_enh_snavn ON SSR (enh_snavn);
CREATE INDEX idx_SSR_enh_snavn_enh_navntype ON SSR (enh_snavn, enh_navntype);
CREATE INDEX idx_n50_arealdekkeflate_objtype ON n50_arealdekkeflate (objtype);
CREATE INDEX idx_n50_adminflate_objtype ON n50_adminflate (objtype);
CREATE INDEX idx_n50_vegsti_vegkategori ON n50_vegsti (vegkategori);
CREATE INDEX idx_n50_vegsti_motorvegtype ON n50_vegsti (motorvegtype);
CREATE INDEX idx_adm_areas_kommuner_navn ON adm_areas_kommuner (navn);
CREATE INDEX idx_adm_areas_fylker_navn ON adm_areas_fylker (navn);
CREATE INDEX idx_adm_areas_gkretsnavn ON adm_areas_grunnkretser (gkretsnavn);

