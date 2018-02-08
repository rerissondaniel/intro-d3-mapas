curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/dados/pb_setores_censitarios.zip

unzip pb_setores_censitarios.zip -d pb_setores_censitarios

sudo npm install -g shapefile

shp2json pb_setores_censitarios/25SEE250GC_SIR.shp -o pb.json

du -hsm pb_setores_censitarios/25SEE250GC_SIR.shp
#7 MB

du -hsm pb.json
#11 MB

less pb.json

npm install -g d3-geo-projection

geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json
  > pb-ortho.json

geo2svg -w 1000 -h 600 < pb-ortho.json > pb-ortho.svg

ndjson-split 'd.features' < pb-ortho.json > pb.ndjson

curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/base-informacoes-censo-universo.pdf

curl -O https://raw.githubusercontent.com/nazareno/intro-d3-mapas/master/dados/PB_20171016.zip

unzip PB_20171016.zip

