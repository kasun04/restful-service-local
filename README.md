# RESTful Service  

In this guide you will learn about building a comprehensive RESTful Web Service using Ballerina. 


## <a name="understanding-the-scenario"></a> Understanding the Scenario  
To understanding how you can build a RESTful web service using Ballerina, let’s consider the order management scenario of an online retail application. 
We can model the order management scenario as a RESTful web service; 'OrderMgtService',  which accepts different HTTP request for order management tasks such as order creation, retrieval, updating and deletion.
The following figure illustrates all required functionalities of the OrderMgt RESTful web service that we need to build. 

![RESTful Service](images/restful_service.png "RESTful Service")


- **Create Order** : To place a new order you can use the HTTP POST message with the content of the order, which is sent to the URL (http://xyz.retail.com/order).The response from the service contains an HTTP 201 Created message with the location header pointing to the newly created resource (http://xyz.retail.com/order/123456). 
- **Retrieve Order** : Now you can retrieve the order details from that URL by sending an HTTP GET request to the appropriate URL which includes the order ID. (e.g. http://xyz.retail.com/order/<orderId>)
- **Update Order** : You can update an existing order by sending a HTTP PUT request with the content for the updated order. 
- **Delete Order** : An existing order can be deleted by sending a HTTP DELETE request to the specific URL (e.g. http://xyz.retail.com/order/<orderId>). 


## <a name="pre-req"></a> Prerequisites
 
- JDK 1.8 or later
- Ballerina Distribution (Install Instructions:  https://ballerinalang.org/docs/quick-tour/quick-tour/#install-ballerina)
- A Text Editor or an IDE 

Optional Requirements
- Docker (Follow instructions in https://docs.docker.com/engine/installation/)
- Ballerina IDE plugins. ( Intellij IDEA, VSCode, Atom)
- Testerina (Refer: https://github.com/ballerinalang/testerina)
- Container-support (Refer: https://github.com/ballerinalang/container-support)
- Docerina (Refer: https://github.com/ballerinalang/docerina)

## <a name="developing-the-scenario"></a> Developing the Scenario

We can model the OrderMgt RESTful service using Ballerina services and resources constructs. 

1. We can get started with a Ballerina service; 'OrderMgtService' which is the RESTful service that serves the order management request. OrderMgtService can have multiple resources and each resource is dedicated for a specific order management functionality.
2. You can decide the package structure for the service and then create the service in the corresponding directory structure. For example, suppose that you are going to use the package name 'guide.restful_service', then you need to create the following directory structure and create the service file using the text editor or IDE that you use. 

```
restful-service
   └── guide
       └── restful_service
           └── OrderMgtService.bal  
```
2. You can add the content to your service as shown below. In that code segment you can find the implementation of the service and resource skeletons of 'OrderMgtService'. 
For each order management operation, there is a dedicated resource and inside each resource we can implement the order management operation logic. 
The service is annotated with the base path for service and each resource has path and HTTP methods based validations, so that we can selectively route the messages through theses resources. 

##### OrderMgtService.bal
```ballerina
package guide.restful_service;

import ballerina.net.http;

@http:configuration {basePath:"/ordermgt"}
service<http> OrderMgtService {


    @http:resourceConfig {
        methods:["GET"],
        path:"/order/{orderId}"
    }
    resource findOrder (http:Connection conn, http:InRequest req, string orderId) {
        // Implementation 
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/order"
    }
    resource addOrder (http:Connection conn, http:InRequest req) {
        // Implementation 
    }

    @http:resourceConfig {
        methods:["PUT"],
        path:"/order/{orderId}"
    }
    resource updateOrder (http:Connection conn, http:InRequest req, string orderId) {
        // Implementation 
    }

    @http:resourceConfig {
        methods:["DELETE"],
        path:"/order/{orderId}"
    }
    resource cancelOrder (http:Connection conn, http:InRequest req, string orderId) {
        // Implementation    
    }
}


```


3. You can implement the business logic of each resources as you perfer. For simplicity we have used an in-memory map to keep the order details. You can find the full source code of the OrderMgtService below. 


##### OrderMgtService.bal
```ballerina
package guide.restful_service;

import ballerina.net.http;

@http:configuration {basePath:"/ordermgt"}
service<http> OrderMgtService {

    map ordersMap = populateSampleOrders();

    @http:resourceConfig {
        methods:["GET"],
        path:"/order/{orderId}"
    }
    resource findOrder (http:Connection conn, http:InRequest req, string orderId) {
        json payload;
        payload, _ = (json)ordersMap[orderId];

        http:OutResponse response = {};
        if (payload == null) {
            payload = "Order : " + orderId + " cannot be found.";
        }
        response.setJsonPayload(payload);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/order"
    }
    resource addOrder (http:Connection conn, http:InRequest req) {
        json orderReq = req.getJsonPayload();
        var orderId, _ = (string) orderReq.Order.ID;
        ordersMap[orderId] = orderReq;

        // Create response message
        json payload = {status:"Order Created.", orderId:orderId};
        http:OutResponse response = {};
        response.setJsonPayload(payload);
        response.statusCode = 201;
        response.setHeader("Location", "http://localhost:9090/ordermgt/order/" + orderId);

        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["PUT"],
        path:"/order/{orderId}"
    }
    resource updateOrder (http:Connection conn, http:InRequest req, string orderId) {

        json newOrder = req.getJsonPayload();

        json existingOrder;
        existingOrder, _ = (json)ordersMap[orderId];

        http:OutResponse response = {};
        if (existingOrder == null) {
            existingOrder = "Order : " + orderId + " cannot be found.";
        }

        existingOrder.Order.Name = newOrder.Order.Name;
        existingOrder.Order.Description = newOrder.Order.Description;

        ordersMap[orderId] = existingOrder;

        response.setJsonPayload(existingOrder);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["DELETE"],
        path:"/order/{orderId}"
    }
    resource cancelOrder (http:Connection conn, http:InRequest req, string orderId) {
        http:OutResponse response = {};
        ordersMap.remove(orderId);
        json payload = "Order : " + orderId + " removed.";
        response.setJsonPayload(payload);
        _ = conn.respond(response);
    }

}

// 
function populateSampleOrders () (map orders) {
    orders = {};
    json order_1 = {"Order":{"ID":"123000", "Name":"ABC_1", "Description":"Sample order."}};
    json order_2 = {"Order":{"ID":"123001", "Name":"ABC_2", "Description":"Sample order."}};
    json order_3 = {"Order":{"ID":"123002", "Name":"ABC_3", "Description":"Sample order."}};
    orders["123000"] = order_1;
    orders["123001"] = order_2;
    orders["123002"] = order_3;

    println("Sample orders are added.");
    return orders;
}

```

4. With that we've completed the development of OrderMgtService. 

## <a name="deploying-the-scenario"></a> Deploying the scenario

Once you are done with the development, you can deploy the service using any of the methods that we listed below. 

### <a name="deploying-on-locally"></a> Deploying Locally
You can deploy the RESTful service that you developed above, in your local machine. You need to have the Ballerina instalation in you local machine and simply point to the <ballerina>/bin/ballerina binary to execute all the following steps.  

1. As the first step you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the directory structure of the service that we developed above and it will create an executable binary out of that. 

```
$ballerina build guide/restful_service
```

2. Once the restful_service.balx is created, you can run it with the following command. 

```
ballerina run restful_service.balx 
```

3. The successful execution of the service should show us the following output. 
```
$ballerina run restful_service.balx 
ballerina: deploying service(s) in 'restful_service.balx'
Sample orders are added.
 
```


### <a name="deploying-on-docker"></a> Deploying on Docker
<Work in progress> 

### <a name="deploying-on-k8s"></a> Deploying on Kubernetes
<Work in progress>

## <a name="testing-the-scenario"></a> Testing 
<Work in progress>

### <a name="invoking-the-service"></a> Testing the Scenario


curl -X POST -d '{ "Order": { "ID": "100500", "Name": "XYZ", "Description": "Sample order."}}'  "http://localhost:9090/ordermgt/order" -H "Content-Type:application/json"

curl "http://localhost:9090/ordermgt/order/100500" 

curl -X PUT -d '{ "Order": {"Name": "XYZ", "Description": "Updated order."}}'  "http://localhost:9090/ordermgt/order/100500" -H "Content-Type:application/json"

curl -X DELETE "http://localhost:9090/ordermgt/order/100500"


### <a name="invoking-the-service"></a> Writing Unit Tests 

<Work in progress> 

