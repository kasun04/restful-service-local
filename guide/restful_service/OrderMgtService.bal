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
