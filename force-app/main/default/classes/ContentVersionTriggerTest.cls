@isTest
public class ContentVersionTriggerTest {
    @isTest    
    static void test1() {
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002266;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = '2686465-AP-BNT-1BN20047';
        insert a;
        
        //sucess records
        ContentVersion cv = new ContentVersion(); 
        cv.String_Version_Data__c = 'VU5BQkxFIFRPIE9CVEFJTiBSU1QgV0VFSyBUSFJVIFZJTiBGT1IgUkVRVUVTVEVEIERFU1RJTkFUSU9OIEJFTE9XIE5PVEVEIE9OIDAyLzI0LzIwMjINCkZyb206IFJlbmVlIFBvd2lzICANClNlbnQ6IFRodXJzZGF5LCBGZWJydWFyeSAyNCwgMjAyMiAxMTozNCBBTQ0KVG86IEVsc2EgQ29uZXJseSA7IEVkd2luIEx1Z28gOyBTdGVwaGFuIENyYW50IA0KQ2M6IEhTSSBUcmF2ZWwgU2FsZXMgTWFuYWdlbWVudCBERyANClN1YmplY3Q6IFJlOiBGdWxmaWxsbWVudC1NYnIjIEFQLUJOVC0xQk4yMDA0Ny1NZW1iZXIgTmFtZSBNQVJLIEdJVkFOUw0KIA0KSGkgRWxzYSwgDQogDQpJIHdhcyB1bmFibGUgdG8gZmluZCBhbnl0aGluZyBpbiB0aGUgcmVxdWVzdGVkIGFyZWFzL2d1bGYgY29hc3QgRkwuIA0KIA0KSWYgZmxleGlibGUgdG8gdGhlIGVhc3QgY29hc3Qgb2YgRkwsIHdlIGhhdmUgYSAzIEJSIE9GIGluIERheXRvbmEgKGluLWhvdXNlKSwgdGhhdCdzIGEgZ3JlYXQgb3B0aW9uIEkgd291bGQgcHVzaC4gDQogDQpUaGFua3MsDQpSZW5lZQ0KIA0KUmVuZWUgUG93aXMgfCBJbnZlbnRvcnkgJiBGdWxmaWxsbWVudCBTcGVjaWFsaXN0IHwgQWR2YW50YWdlIFByb2dyYW0gfCBUZWwuICg4ODgpIDMxNS01Nzc4ICB4MjMxOQ0KDQoNCg0KRnJvbTogRWxzYSBDb25lcmx5IEVsc2EuQ29uZXJseUBBZHZhbnRhZ2VQcm9ncmFtLmNvbT4NClNlbnQ6IFRodXJzZGF5LCBGZWJydWFyeSAyNCwgMjAyMiAyOjA4IFBNDQpUbzogRWR3aW4gTHVnbyBlZHdpbi5sdWdvQHZhY2F0aW9uaW5ub3ZhdGlvbnMuY29tPjsgU3RlcGhhbiBDcmFudCBTdGVwaGFuLkNyYW50QEFkdmFudGFnZVByb2dyYW0uY29tPjsgUmVuZWUgUG93aXMgUmVuZWUuUG93aXNAQWR2YW50YWdlUHJvZ3JhbS5jb20+DQpDYzogSFNJIFRyYXZlbCBTYWxlcyBNYW5hZ2VtZW50IERHIGhzaV90cmF2ZWxzYWxlc21nbXRAYWR2YW50YWdlcHJvZ3JhbS5jb20+DQpTdWJqZWN0OiBGdWxmaWxsbWVudC1NYnIjIEFQLUJOVC0xQk4yMDA0Ny1NZW1iZXIgTmFtZSBNQVJLIEdJVkFOUyANCiANCkhlbGxvLA0KIA0KTG9jYXRpb24gUmVxdWVzdGVkOiBEZXN0aW4vT3JhbmdlIEJlYWNoL1BlbnNpY29sYS9HdWxmIFNob3JlcyAmIFBhbmFtYSBDaXR5IEJlYWNoDQpVbml0IFNpemU6IDNCRFJNIG9yIDJCRFJNDQpOdW1iZXIgb2YgVHJhdmVsZXJzOiA2IEFEVUxUUw0KUHJlZmVycmVkIERhdGVzOiBKdW5lIDE4LTI1LCAyMDIyDQpBcmUgdGhleSBmbGV4aWJsZTogTm8NCkFsdGVybmF0ZSBEYXRlIGFuZC9vciBMb2NhdGlvbjogTm8NCiANCkVsc2EgQ29uZXJseSB8IFRyYXZlbCBTYWxlcyBBZ2VudCB8IEhvbGlkYXkgU3lzdGVtcyBJbnRlcm5hdGlvbmFsIHwgVGVsOiA4MDAuMzUzLjA3NzQgIEV4dDogMjI5NQ0K';
        cv.Title = 'Contact';
        cv.PathOnClient = 'Contact.snote';
        //cv.VersionData = Blob.valueOf('tempnote');
        cv.Note_Id__c = 'CNH45796577';
        //cv.FirstPublishLocationId = a.Id;
        cv.Master_Record_Id__c = '2686465-AP-BNT-1BN20047';
        insert cv;
        
        //failed record
        try{
            ContentVersion cv2 = new ContentVersion(); 
            cv2.String_Version_Data__c = 'Galván';
            cv2.Title = 'Contact2';
            cv2.PathOnClient = 'Contact2.snote';
            //cv.VersionData = Blob.valueOf('tempnote');
            cv2.Note_Id__c = 'CNH45796578';
            //cv2.FirstPublishLocationId = a.Id;
            cv2.Master_Record_Id__c = 'XXXXXXX-XX-XXX-XXXXXXXX';            
            insert cv2;
        }
        catch(Exception e)
        {
            System.debug('error : '+e.getMessage());
        }
    }
    @isTest    
    static void Test2() {
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002266;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = '2686465-AP-BNT-1BN20047';
        insert a;
        
        //sucess records
        ContentVersion cv = new ContentVersion(); 
        cv.String_Version_Data__c = '©™“”â€Â¶˜ƒ><|Custom Email sent from B.E. to adrian@adrianguzman.com.mx; juanmrl2014@gmail.com, From service@advantageprogram.net Subject: Advantage Program/My Travel Rewards Club Message:   Hola Adrian,  &iexcl;Este es un correo oficial para darle la Bienvenida y tambi&eacute;n darle las gracias por hacer negocio con nosotros, realmente lo apreciamos!   Yo espero que su membres&iacute;a My Travel Rewards Club sea emocionante como lo es para m&iacute; ya que AMO viajar, y esta es una de muchas oportunidades para que usted lo pueda hacer.   DISPONIBLE PARA USTED YA MISMO (sujeto a disponibilidad y por tiempo l&iacute;mite)   Un certificado de vacaciones por 7-noches en M&eacute;xico, valido para una habitaci&oacute;n tipo estudio (Max ocup. 4personas 2adl/2chl) en uno de nuestros top resorts en M&eacute;xico, de la Cadena VIDANTA! Estos resorts son resorts 5-estrellas y est&aacute;n valorizados por encima de los $2,500 sobre la tarifa general para el p&uacute;blico, nuestros miembros solo pagan $699.00 por la semana (Algunas propiedas estan sujeta a fee por ascendeer de categoria) Usted podr&aacute; ver estas hermosas propiedades en estupendos destinos, visite la p&aacute;gina web  www.vidanta.com    Y como recordatorio de los beneficios de Advantage Program:  Su membres&iacute;a Advantage Program le proporciona una amplia variedad de servicios Exclusivos. Advantage Program ser&aacute; su fuente &uacute;nica para cada viaje que necesite. Como miembro, el concepto de MEMBRESIA ser&aacute; para usted m&aacute;s que una membres&iacute;a, y encontrar&aacute; m&aacute;s valor que cualquier otra compa&ntilde;&iacute;a dentro de esta industria.   Advantage Program: le GARANTIZA las tarifas m&aacute;s bajas no disponibles para el p&uacute;blico en general. Los miembros de Advantage Program se ahorra miles de d&oacute;lares cada a&ntilde;o usando los privilegios exclusivos de la membres&iacute;a.   Advantage Credits: Cada vez que usted reserve un viaje con nosotros v&iacute;a telef&oacute;nica o a trav&eacute;s de la p&aacute;gina web www.mytravelrewardsclub.com usted ganara cr&eacute;ditos, y estos le son depositados en su cuenta de miembro y los podr&iacute;a utilizar para futuros viajes. Estos se gastan d&oacute;lar por d&oacute;lar, y no tienen fecha de expiraci&oacute;n.  Usted los puede usar para cualquier tipo de viaje, excepto para renta de autos, tiquetes a&eacute;reos promocion con Vidanta.     Advantage Credits: Cada vez que usted reserve con nosotros o a trav&eacute;s de la p&aacute;gina web www.mytravelrewardsclub.com usted gana cr&eacute;ditos, estos se acumularan en su cuenta MTRC y los podr&aacute; usar para futuras reservas.  They spend dollar for dollar, and they do not expire.  You can use them for any type of travel arrangements except for air and car rentals.   $699 Resort Week: Usted tiene tres Semanas Vacacionales al a&ntilde;o de $699. Una vez las use, usted podr&aacute; continuar reservando Semanas Vacacionales a precios regulares con precios de miembros. Travel Cash: Efectivo de viajes o cr&eacute;ditos los puede usar para hoteles, semanas vacacionales regulares y cruceros. ###Efectivo de viaje o cr&eacute;dito NO se puede usar para la semana al a&ntilde;o de $699 y tampoco para las tarifas especiales que tiene con Vidanta ###   Advantage Week&trade;: Semanas vacacionales a precios bajos GARANTIZADOS o le pagamos el doble de la diferencia en efectivo! &iexcl;Los miembros se pueden ahorrar m&aacute;s de $5,000 en una estad&iacute;a de 7-noches! Estas no est&aacute;n limitadas a ofertas de ultimo minutos o fuera de temporada.    &iexcl;Mas de 500,000 de los mejores hoteles del mundo al precio m&aacute;s bajo GARANTIZADO o le devolvemos el doble de la diferencia en efectivo! &iexcl;Todas las principales l&iacute;neas de Cruceros al precio m&aacute;s bajo GARANTIZADO o le devolvemos el doble de la diferencia en efectivo! &iexcl;Mas de 8,000 de los m&aacute;s populares paquetes de tours en el mundo al precio m&aacute;s bajo GARANTIZADO o le devolvemos el doble de la diferencia en efectivo!  5,000 de los paquetes de eventos deportivos m&aacute;s populares del mundo al precio m&aacute;s bajo GARANTIZADO o le devolvemos el doble de la diferencia en efectivo!  Vacaciones a su estilo son vacaciones exclusivas creadas por usted mismo. re&uacute;na todos los componentes de viaje que desea para disfrutar de una experiencia exclusiva y personal; &iexcl;al precio m&aacute;s bajo GARANTIZADO o le devolvemos el doble de la diferencia en efectivo! &iexcl;Mas de 400,000 Actividades en m&aacute;s de 5,000 ciudades del mundo! Conserje: Disfrute de la comodidad de tener un conserje privado en l&iacute;nea que le asistir&aacute; con todas sus necesidades.  Servicio VIP de tiquetes a&eacute;reos: Disfrute del servicio royal que se merece a trav&eacute;s del servicio de conserje personal. &iexcl;Su tiempo es valioso! Si&eacute;ntese y deje que Advantage Program haga todo por usted. Los miembros se ahorran hasta $50 por boleto a&eacute;reo. Servicios de Spa y Paquetes de Spa: &iexcl;Disfrute de precios exclusivos en paquetes y servicios de Spa en m&aacute;s de 4,000 spa alrededor del mundo! Espect&aacute;culos y Eventos: Disfrute de precios especiales en entradas a eventos y espect&aacute;culos seleccionados en miles de lugares a trav&eacute;s de su membres&iacute;a Advantage Program. Descuento en Renta de Autos: Disfrute de los mejores veh&iacute;culos, con millas ilimitadas en ofertas especiales, otros descuentos y promociones.     Si tiene dudas o preguntas de c&oacute;mo usar sus servicios y aprovechar al m&aacute;ximo sus servicios incluidos en su membres&iacute;a Advantage Program, por favor no dude en contactarme a los n&uacute;meros de tel&eacute;fono que se encuentran abajo, Horas de oficina Lunes a Viernes de 7am a 3:30pm (PST), estar&eacute; m&aacute;s que feliz de poderle asistir.      Cordial saludo,     Cristina Ruiz | Travel Sales |Advantage Program/My Travel Rewards Club |P.O.Box 35076 Las Vegas, Nevada 89133-5076 |Tel: 702.789.2933 Ext. 2301 |Toll Free from U.S/Canada 877.672.7144  &ldquo;Una vez al a&ntilde;o, ve a un lugar donde nunca antes hayas estado&rdquo;- Dalai Lama  www.mytravelrewardsclub.com / www.advantageprogram.net/ maria.ruiz@advantageprogram.com      Advantage Services  PO Box 35076 Las Vegas, NV 89133 Office: 702-304-4604 Toll Free from U.S./Canada: 877-304-4604 Private Fax: 702-254-8760';
        cv.Title = 'Contact';
        cv.PathOnClient = 'Contact.snote';
        //cv.VersionData = Blob.valueOf('tempnote');
        cv.Note_Id__c = 'CNH45796577';
        cv.FirstPublishLocationId = a.Id;
        //cv.Master_Record_Id__c = '2686465-AP-BNT-1BN20047';
        insert cv;        
    }
}