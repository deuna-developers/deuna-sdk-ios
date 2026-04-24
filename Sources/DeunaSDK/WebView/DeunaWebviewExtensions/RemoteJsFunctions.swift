import Foundation

//
//  RemoteJsFunctions.swift
//  DeunaSDK
//
//  Created by deuna on 27/3/25.
//

extension DeunaWebViewController {
    /// Send the custom styles to the widget link
    func setCustomStyle(data: Json) {
        if let jsonString = data.encode() {
            controller.webView?.evaluateJavaScript("javascript:setCustomStyle(\(jsonString),'*')")
        }
    }
    
    func refetchOrder(completion: @escaping (Json?) -> Void) {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                (function() {
                    \(self.controller.buildResultFunction(requestId: requestId, type: "refetchOrder"))

                    if(typeof window.deunaRefetchOrder !== 'function'){
                        sendResult({ order:null });
                        return;
                    }
                
                    window.deunaRefetchOrder()
                    .then(sendResult)
                    .catch(error => sendResult({ order:null }));
                })();
                """
            },
            completion: { data in
                let order = data["order"] as? Json
                completion(order)
            }
        )
    }
    
    func isValid(completion: @escaping (Bool) -> Void) {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                (function() {
                    \(self.controller.buildResultFunction(requestId: requestId, type: "isValid"))
                    if(typeof window.isValid !== 'function'){
                        sendResult({isValid:false});
                        return;
                    }
                    sendResult( {isValid: window.isValid() });
                })();
                """
            },
            completion: { json in
                completion(json["isValid"] as! Bool)
            }
        )
    }
    
    func submit(completion: @escaping (SubmitResult) -> Void) {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                (function() {
                    \(self.controller.buildResultFunction(requestId: requestId, type: "submit"))
                    if(typeof window.submit !== 'function'){
                        console.log('window.submit undefined');
                        sendResult({status:"error", message:"Error al procesar la solicitud." });
                        return;
                    }
                    window.submit()
                    .then(sendResult)
                    .catch(error => sendResult({status:"error", message: error.message ?? "Error al procesar la solicitud." }));
                })();
                """
            },
            completion: { data in
                print(data)
                completion(SubmitResult.from(dictionary: data))
            }
        )
    }
    
    func getWidgetState(completion: @escaping (Json?) -> Void) {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                (function() {
                    \(self.controller.buildResultFunction(requestId: requestId, type: "getWidgetState"))
                    if(!window.deunaWidgetState){
                        sendResult({ deunaWidgetState: null });
                        return;
                    }
                    sendResult({ deunaWidgetState: window.deunaWidgetState });
                })();
                """
            },
            completion: { data in
                completion(data["deunaWidgetState"] as? Json)
            }
        )
    }
    
    public func takeScreenshot(completion: @escaping () -> Void) {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                            (function() {
                                \(self.controller.buildResultFunction(requestId: requestId, type: "takeScreenshot"))
                                function takeScreenshot() {
                                    html2canvas(document.body, { allowTaint: true, useCORS: true }).then((canvas) => {
                                        // Convert the canvas to a base64 image
                                        var imgData = canvas.toDataURL("image/png");
                                        sendResult({imgData:imgData});
                                    }).catch((error) => {
                                        sendResult({imgData: null});
                                    });
                                }

                                // If html2canvas is not added
                                if (typeof html2canvas === "undefined") {
                                    var script = document.createElement("script");
                                    script.src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js";
                                    script.onload = function () {
                                        takeScreenshot();
                                    };
                                    document.head.appendChild(script);
                                } else {
                                    takeScreenshot();
                                }
                            })();
                """
            },
            completion: { data in
                if let imgData = data["imgData"] as? String {
                    Base64ImageDownloader(imgData, viewController: self).save()
                }
                completion()
            }
        )
    }
}
