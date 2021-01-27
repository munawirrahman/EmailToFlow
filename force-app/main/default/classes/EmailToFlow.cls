/* @author: Munawir
 * @authorEmail: munawirrahman@gmail.com
 * @authorMedium: https://medium.com/@munawirrahman
 * @Description: Email Service Router to Salesforce Flow Builder
 */

global class EmailToFlow implements Messaging.inboundEmailHandler{
 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult AutoReply = new Messaging.InboundEmailResult();
        
        //Assigning values from email and envelope to variable make it easier to read
        String Envelope_FromAddress = env.FromAddress;
        String Envelope_ToAddress = env.ToAddress;
        List<String> Email_ToAddresses = email.ToAddresses;
        String Email_FromName = email.FromName;
        String Email_FromAddress = email.FromAddress;
        List<String> Email_CCAddresses = email.CCAddresses;
        String Email_Subject = email.Subject;
        String Email_ReplyTo = email.ReplyTo;
        String Email_InReplyTo = email.InReplyTo;
        String Email_MessageId = email.MessageId;
        List<String> Email_References = email.References;
        String Email_HTMLBody = email.HTMLBody;
        Boolean Email_IsHTMLTruncated = email.HTMLBodyIsTruncated;
        String Email_TextBody = email.PlainTextBody;
        Boolean Email_IsTextBodyTruncated = email.PlainTextBodyIsTruncated;
        List<ContentVersion>Email_ContentVersion = ConvertAttachmentsToCV(email);
        
        Map<String, Object> MapFlow = new Map<String, Object>();
        MapFlow.put('Envelope_FromAddress', Envelope_FromAddress);
        System.debug('Input to Flow var Envelope_FromAddress: '+ Envelope_FromAddress);
        MapFlow.put('Envelope_ToAddress', Envelope_ToAddress);
        System.debug('Input to Flow var Envelope_ToAddress: '+ Envelope_ToAddress);
        MapFlow.put('Email_ToAddresses', Email_ToAddresses);
        System.debug('IInput to Flow var Email_ToAddresses: '+ Email_ToAddresses);
        MapFlow.put('Email_FromName', Email_FromName);
        System.debug('Input to Flow var Email_FromName: '+ Email_FromName);
        MapFlow.put('Email_FromAddress', Email_FromAddress);
        System.debug('Input to Flow var Email_FromAddress: '+ Email_FromAddress);
        MapFlow.put('Email_CCAddresses', Email_CCAddresses);
        System.debug('Input to Flow var Email_CCAddresses: '+ Email_CCAddresses);
        MapFlow.put('Email_Subject', Email_Subject);
        System.debug('Input to Flow var Email_Subject: '+ Email_Subject);
        MapFlow.put('Email_ReplyTo', Email_ReplyTo);
        System.debug('Input to Flow var Email_ReplyTo: '+ Email_ReplyTo);
        MapFlow.put('Email_MessageId', Email_MessageId);
        System.debug('Input to Flow var Email_MessageId: '+ Email_MessageId);
        MapFlow.put('Email_References', Email_References);
        System.debug('Input to Flow var Email_References: '+ Email_References);
        MapFlow.put('Email_HTMLBody', Email_HTMLBody);
        System.debug('Input to Flow var Email_HTMLBody: '+ Email_HTMLBody);
        MapFlow.put('Email_IsHTMLTruncated', Email_IsHTMLTruncated);
        System.debug('Input to Flow var Email_IsHTMLTruncated: '+ Email_IsHTMLTruncated);
        MapFlow.put('Email_TextBody', Email_TextBody);
        System.debug('Input to Flow var Email_TextBody: '+ Email_TextBody);
        MapFlow.put('Email_IsTextBodyTruncated', Email_IsTextBodyTruncated);
        System.debug('Input to Flow var Email_IsTextBodyTruncated: '+ Email_IsTextBodyTruncated);
        MapFlow.put('Email_ContentVersion',Email_ContentVersion);
        System.debug('Input to Flow var Email_ContentVersion: '+ Email_ContentVersion);
        System.debug(MapFlow);
        
        System.debug('Running flow...');
        
        //EmailToFlowController = autolaunched flow api name
        Flow.Interview.EmailToFlowController myFlow = new Flow.Interview.EmailToFlowController(MapFlow);
		myFlow.start();
        System.debug('Flow finished.');
        //AutoReply Email to Sender but AutoReply_Message should be assigned in flow
        if(myFlow.AutoReplyMessage != Null){
            System.debug('myFlow AutoReply Message: '+ myFlow.AutoReplyMessage);
            AutoReply.message = myFlow.AutoReplyMessage;
        }
        return AutoReply;
    }
    
    //Convert All Attachments to List of ContentVersion
    private static List<ContentVersion>ConvertAttachmentsToCV(Messaging.InboundEmail email){
        ContentVersion CVRecord = new ContentVersion();
        List<ContentVersion>CVRecords = new List<ContentVersion>();
        //Convert binary attachments to ContentVersion
        if (email.BinaryAttachments != null && !email.BinaryAttachments.isEmpty()){
            for (Messaging.InboundEmail.BinaryAttachment BinAttach : email.BinaryAttachments){
                CVRecord.Title = BinAttach.FileName;
                CVRecord.VersionData = BinAttach.Body;
                CVRecord.PathOnClient = '/' + BinAttach.FileName ;
                CVRecords.add(CVRecord);
            }
        }
        //Convert text attachments to PDF ContentVersion
        if (email.TextAttachments != null && !email.TextAttachments.isEmpty()){
            for (Messaging.InboundEmail.TextAttachment TextAttach : email.TextAttachments){
                CVRecord.Title = TextAttach.FileName;
                CVRecord.VersionData = Blob.ToPDF(TextAttach.Body);
                CVRecord.PathOnClient = '/' + TextAttach.FileName.Replace('.','') + '.pdf' ;
                CVRecords.add(CVRecord);
            }
        }
        //return only if Attachments exist
        if(CVRecords != null && !CVRecords.isEmpty()){
            return CVRecords;
        }
        else{
            return null;
        }
    }
}