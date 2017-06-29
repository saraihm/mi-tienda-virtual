//
//  Constants.h
//  PPrueba
//
//  Created by Sarai Henriquez on 14-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


//URL Country Infixes for GS services

#define kTestInfixCL        @"gsellingclts"
#define kTestInfixAR        @"gsellingarts"
#define kTestInfixPE        @"gsellingpets"
#define kTestInfixCO        @"gsellingcots"

#define kProdInfixCL        @"gsellingcl"
#define kProdInfixAR        @"gsellingar"
#define kProdInfixPE        @"gsellingpe"
#define kProdInfixCO        @"gsellingco"

//URL Country Infixes for F12 services

#define kF12InfixCL        @"F12CL"
#define kF12InfixAR        @"F12AR"
#define kF12InfixPE        @"F12PE"
#define kF12InfixCO        @"F12CO"

//Country Currency codes

#define kCurrencyCL     @"clp"
#define kCurrencyAR     @"ars"
#define kCurrencyPE     @"pen"
#define kCurrencyCO     @"cop"

#define kMainDomain         @kKeyBaseUrl
#define kUrlFalabellaProduction         @"guideselling.falabella.com/%@/"

#define kMainCountry        @"country"
#define kBaseURLProtocol                    @"http://"
#define kBaseURLSecureProtocol              @"https://"
#define kBaseURLString                      kUrlMotionDisplaysProduction
#define kUrlParisProduction         @"guideselling.falabella.com/%@/"
//#define kUrlMotionDisplaysProduction    @"www.motiondisplays.cl:7000/GuidedSelling/"
#define kUrlMotionDisplaysProduction  @"paris.motiondisplays.cl:3000/"
#define kUrlParisTest               @"testguidesellingv2.falabella.cl/%@/"

//WS API Error Definitions

#define kMDErrorReachability                        @"No se ha podido establecer conexión, por favor verifique su configuración de red"

#define kMDErrorNullResponse                        @"Ha ocurrido un error durante el procesamiento de su solicitud"
#define kMDErrorEmptyUnsuccessfullResponse          @"Sin resultados ni coincidencias"
#define kMDErrorUnknowError                         @"Ha ocurrido un error durante el procesamiento de su solicitud (Código %@)"
#define kMDErrorInvalidParameterContent             kMDErrorUnknowError
#define kMDErrorInvalidParameterFormat              kMDErrorUnknowError
#define kMDErrorInvalidSessionToken                 @"La sesión ha caducado, por favor inicie su sesión nuevamente"
#define kMDErrorInvalidUsernameOrPassword1           @"El usuario o la contraseña ingresados son inválidos"
#define kMDErrorInvalidUsernameOrPassword2           @"El usuario o la contraseña ingresados son inválidos. \nIntentos posibles: 3. \nIntentos realizados %@."
#define kMDErrorBuildOrVersionNumberUnauthorized    kMDErrorUnknowError
#define kMDErrorInvalidSku                          @"El producto solicitado se ha agotado o es inválido"
#define kMDErrorInvalidCourse                       @"El curso seleccionado ya no se encuentra disponible"
#define kMDErrorSalesLimitExceded                   @"El tramo de fechas elegido es muy amplio, por favor intente con un tramo mas corto"
#define kMDErrorInvalidStoreId                      @"La tienda a la cual desea acceder no es válida, comunicarse con soporte"
#define kMDErrorBlockedUser                         @"El usuario ha sido bloqueado, por favor contactese con la persona a cargo para solicitar desbloqueo"
#define kMDErrorProductNotAvailableTitle            @"Producto no disponible"
#define kMDErrorProductNotAvailableMessage          @"Por favor seleccione otro producto"




#endif /* Constants_h */
