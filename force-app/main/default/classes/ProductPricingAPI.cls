/*
 Created By 	: Mitul
 Created Date 	: 4/02/2021
 Perpose		: This clsse used to get the Product Id and Product Unit Price based on product Id pass by customer
 Used			: For Checkout website when end user click on url based on product Id this class return the product name and product price

*/

@RestResource(urlMapping='/ProductPricingAPI/*')
global with sharing class ProductPricingAPI {
    @HttpGet
    global static ProductDetailsReturn ProductPricing() {
        try{
             RestRequest request = RestContext.request;
            // grab the ProductId from the end of the URL
            String productId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('--request---'+request);
            system.debug('--productId--'+productId);
            if(productId.contains('%20')){
                productId = productId.replace('%20', ' ');
            }
            system.debug('--productId--'+productId);
            List<Pricebookentry> priceookList = new List<Pricebookentry>();
            if(productId != null && productId != ''){
                priceookList  = [SELECT Id,Name,Product2.Id,Product2.Name,UnitPrice FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id =: productId];
            }
          
            if(priceookList.size() > 0){
                ProductDetailsReturn wrp = new ProductDetailsReturn();
                wrp.APIstatus = 'SUCCESS';
                wrp.error_Message = null;
                wrp.productName = priceookList[0].Product2.Name;
                wrp.UnitPrice = priceookList[0].UnitPrice;
                if(priceookList[0].Product2.Name == 'Voucher-Vidanta SMTN'){
                    wrp.minimumPrice = 49.00;
                    wrp.priceValidation = true;
                }
                else{
                    wrp.minimumPrice = 0.00;
                    wrp.priceValidation = false;
                }
                if(priceookList[0].Product2.Name == 'Voucher-Vidanta'){
                	wrp.minimumPrice = 99.00;
                    wrp.priceValidation = true;
                }else{
                    wrp.minimumPrice = 0.00;
                    wrp.priceValidation = false;
                }
                if(priceookList[0].Product2.Name == 'Voucher-Serenity'){
                	wrp.minimumPrice = 150.00;
                    wrp.priceValidation = true;
                }else{
                    wrp.minimumPrice = 0.00;
                    wrp.priceValidation = false;
                }
                return  wrp;
            }else{
                ProductDetailsReturn wrp = new ProductDetailsReturn();   
                wrp.APIstatus = 'ERROR';
                wrp.error_Message = 'Product Id is not valid';
                return wrp;
            }
        }catch(Exception e){
            system.debug('--e---'+e+'linenumber'+e.getLineNumber());
        }
        return null;
    }
    global class ProductDetailsReturn{
        webservice String APIstatus;
        webservice String error_Message;
        webservice String productName;
        webservice decimal UnitPrice;
        webservice decimal minimumPrice;
        webservice boolean priceValidation;
 	}
}