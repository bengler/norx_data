# This SQL is to fix encoding errors from the LATIN1 dump of n50_arealdekkeflate provided by Statens kartverk.

# Change encoding on objtype column
UPDATE n50_arealdekkeflate SET objtype=convert_from(objtype::bytea, 'LATIN1')
  WHERE objtype::bytea<>convert_from(objtype::bytea, 'LATIN1')::bytea;
UPDATE n50_arealdekkeflate SET objtype=convert(objtype::bytea, 'LATIN1','UTF8')::my_varlena::text
  WHERE str::bytea<>convert(str::bytea, 'LATIN1', 'UTF8');

# Fix objtype values with wrong encoding in N50_arealdekkeflate.
update n50_arealdekkeflate set objtype = 'ÅpentOmråde' where objtype like  '%pentOmr%';
update n50_arealdekkeflate set objtype = 'FerskvannsTørrfall' where objtype = 'FerskvannTÃ¸rrfall';
update n50_arealdekkeflate set objtype = 'SnøIsbre' where objtype = 'SnÃ¸Isbre';
update n50_arealdekkeflate set objtype = 'Innsjø' where objtype = 'InnsjÃ¸';
update n50_arealdekkeflate set objtype = 'Industriområde' where objtype = 'IndustriomrÃ¥de';
