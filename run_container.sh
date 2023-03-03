docker rm -f shardingsphere
docker run -d --name shardingsphere \
    -v $PWD/conf:/opt/shardingsphere-proxy/conf \
    -v $PWD/ext-lib:/opt/shardingsphere-proxy/ext-lib \
    -p 3307:3307 apache/shardingsphere-proxy:5.3.1
