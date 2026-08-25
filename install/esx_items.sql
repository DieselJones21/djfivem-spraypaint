-- ESX item rows (skip this if you use ox_inventory — use ox_inventory_items.lua instead)

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('chameleonpaint_161', '#161 Monochrome Spray', 1, 0, 1),
('chameleonpaint_162', '#162 Night & Day Spray', 1, 0, 1),
('chameleonpaint_163', '#163 The Verlierer Spray', 1, 0, 1),
('chameleonpaint_164', '#164 Sprunk Extreme Spray', 1, 0, 1),
('chameleonpaint_165', '#165 Vice City Spray', 1, 0, 1),
('chameleonpaint_166', '#166 Synthwave Nights Spray', 1, 0, 1),
('chameleonpaint_167', '#167 Four Seasons Spray', 1, 0, 1),
('chameleonpaint_168', '#168 Maisonette 9 Throwback Spray', 1, 0, 1),
('chameleonpaint_169', '#169 Bubblegum Spray', 1, 0, 1),
('chameleonpaint_170', '#170 Full Rainbow Spray', 1, 0, 1),
('chameleonpaint_171', '#171 Sunset Spray', 1, 0, 1),
('chameleonpaint_172', '#172 The Seven Spray', 1, 0, 1),
('chameleonpaint_173', '#173 Kamen Rider Spray', 1, 0, 1),
('chameleonpaint_174', '#174 Chromatic Aberration Spray', 1, 0, 1),
('chameleonpaint_175', '#175 Its Christmas! Spray', 1, 0, 1),
('chameleonpaint_176', '#176 Temperature Spray', 1, 0, 1)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);
