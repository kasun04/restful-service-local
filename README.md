# RESTful Service 

Building a RESTful web service using Ballerina. 



ballerina build guide/restful_service
ballerina run restful_service.balx 


![RESTful Service](images/restful_service.png "RESTful Service")



curl -X POST -d '{ "Order": { "ID": "100500", "Name": "XYZ", "Description": "Sample order."}}'  "http://localhost:9090/ordermgt/order" -H "Content-Type:application/json"

curl "http://localhost:9090/ordermgt/order/100500" 

curl -X PUT -d '{ "Order": {"Name": "XYZ", "Description": "Updated order."}}'  "http://localhost:9090/ordermgt/order/100500" -H "Content-Type:application/json"

curl -X DELETE "http://localhost:9090/ordermgt/order/100500"