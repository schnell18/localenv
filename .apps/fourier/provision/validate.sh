grpcurl --plaintext localhost:24001 list
grpcurl -vv --plaintext -d '{"appName": "Justin", "rule": "card12", "batchSize": 20, "batchNo": 242343 }' \
        localhost:24001 fourier.secret.CypherGenService.generate
