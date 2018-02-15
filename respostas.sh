curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/dados/pb_setores_censitarios.zip

unzip pb_setores_censitarios.zip -d pb_setores_censitarios

shp2json pb_setores_censitarios/25SEE250GC_SIR.shp -o pb.json

du -hsm pb_setores_censitarios/25SEE250GC_SIR.shp
#7 MB

du -hsm pb.json
#11 MB

geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json \
  > pb-ortho.json

geo2svg -w 1000 -h 600 < pb-ortho.json > pb-ortho.svg

ndjson-split 'd.features' < pb-ortho.json > pb.ndjson

curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/base-informacoes-censo-universo.pdf

curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/dados/PB_20171016.zip

unzip PB_20171016.zip

dsv2json -r ';' -n PB/Base\ informaçoes\ setores2010\ universo\ PB/CSV/Pessoa10_PB.csv

ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' < pb.ndjson > pb-censo-ortho-sector.ndjson

ndjson-join 'd.Cod_setor'  pb-censo-ortho-sector.ndjson pb-censo.ndjson > pb-mapa-com-dados.ndjson

ndjson-map 'd[0].properties = {porcent_com_registro: d[1].V001 * 100 / (d[1].V001 + d[1].V002 + d[1].V003) * 100}' < pb-mapa-com-dados.ndjson > pb-ortho-com-registro.ndjson

geo2topo -n tract=pb-ortho-com-registro.ndjson > pb-tracts-topo.json

toposimplify -p 1 -f < pb-tracts-topo.json | topoquantize 1e5 > pb-quantized-topo.json

topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 \
  'z = d3.scaleSequential(d3.interpolateViridis).domain([0, 1e3]), d.features.forEach(f => f.properties.fill = z(f.properties.porcent_com_registro)), d' \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
  > pb-tracts-threshold-light.svg

