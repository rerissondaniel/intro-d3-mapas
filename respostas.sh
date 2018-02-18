shp2json pb_setores_censitarios/25SEE250GC_SIR.shp -o pb.json

geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json \
  > pb-ortho.json

geo2svg -w 1000 -h 600 < pb-ortho.json > pb-ortho.svg

ndjson-split 'd.features' < pb-ortho.json > pb-ortho.ndjson

dsv2json -r ';' -n < PB/Base\ informaçoes\ setores2010\ universo\ PB/CSV/Pessoa10_PB.csv > pb-censo.ndjson

ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' < pb-ortho.ndjson > pb-censo-ortho-sector.ndjson

ndjson-join 'd.Cod_setor'  pb-censo-ortho-sector.ndjson pb-censo.ndjson > pb-ortho-dados.ndjson

ndjson-map 'd[0].properties = {porcent_com_registro: d[1].V001 * 100 / (d[1].V001 + d[1].V002 + d[1].V003) * 100}, d[0]' < pb-ortho-dados.ndjson > pb-ortho-registro.ndjson

geo2topo -n tracts=pb-ortho-registro.ndjson > pb-tracts-topo.json

toposimplify -p 1 -f < pb-tracts-topo.json | topoquantize 1e5 > pb-quantized-topo.json

topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 -r d3=d3-scale-chromatic\
  'z = d3.scaleThreshold().domain([98, 98.25, 98.5, 98.75, 99, 99.25, 99.5, 99.75, 100]).range(d3.schemeBuGn[9]), d.features.forEach(f => f.properties.fill = z(f.properties.porcent_com_registro)), d' \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 > pb-tracts-threshold-light.svg