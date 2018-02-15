topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 -r d3=d3-scale-chromatic\
  'z = d3.scaleThreshold().domain([99, 99.2, 99.5, 99.7, 100]).range(d3.schemeBuGn[4]), d.features.forEach(f => f.properties.fill = z(f.properties.porcent_com_registro)), d' \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
