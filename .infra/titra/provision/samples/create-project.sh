curl 'http://localhost:3000/project/create/' \
    -H 'Content-Type: application/json; charset=UTF-8' \
    -H 'Accept: */*' \
    -H 'Authorization: Token: ribxxexkaxcPRoEeN' \
    -d'{
        "name": "Sample-Project-1",
        "description": "Sample Project 1",
        "color": "#009688",
        "customer": "PPL",
        "rate": 100,
        "budget": 50
}
'
