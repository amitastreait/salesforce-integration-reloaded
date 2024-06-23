/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class AWSErrorXmlParser {
    public static AWSErrorWrapper parseXmlResponse(String xmlResponse) {
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
            
            Dom.XMLNode rootNode = doc.getRootElement();
            
            String code 		= rootNode.getChildElement('Code', null).getText();
            String message 		= rootNode.getChildElement('Message', null).getText();
            String requestId 	= rootNode.getChildElement('RequestId', null).getText();
            String hostId 		= rootNode.getChildElement('HostId', null).getText();
            
            AWSErrorWrapper wrapper = new AWSErrorWrapper();
            wrapper.code 		= code;
            wrapper.message 	= message;
            wrapper.requestId 	= requestId;
            wrapper.hostId 		= hostId;
            
            return wrapper;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new XmlException( e.getMessage() );
        }
    }
}