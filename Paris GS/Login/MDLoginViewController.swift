//
//  MDLoginViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez - Sarai Henriquez on 22-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import CoreLocation
import Crashlytics

class MDLoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var lbBuildAndVersion: UILabel!
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var btLogin: UIButton!
    let userDefault = UserDefaults.standard
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
          
        self.navigationController?.isNavigationBarHidden = true;
       
        MDTools.addShadowTo(view: self.viewLogin)
               
        //Add border color and icon to textfields
        let icon = UIImageView.init(image: UIImage.init(named: "ic_user"))
        icon.frame = CGRect(x:0, y:0, width:45, height:20);
        self.txtUsuario.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        self.txtUsuario.layer.borderWidth = 1.0;
        self.txtUsuario.leftView = icon;
        self.txtUsuario.leftViewMode = .always;
        
        let iconPass = UIImageView.init(image: UIImage.init(named: "ic_pass"))
        iconPass.frame = CGRect(x:0, y:0, width:45, height:20);
        self.txtContrasena.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        self.txtContrasena.layer.borderWidth = 1.0;
        self.txtContrasena.leftView = iconPass;
        self.txtContrasena.leftViewMode = .always;
        
        //Blur effect
        imgBackground.image = imgBackground.image?.applyBlurWithRadius(blurRadius: 2, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.0)
        
        btLogin.layer.cornerRadius = kCornerRadiusButton
        
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        lbBuildAndVersion.text = "Build " + String(describing: buildNumber!) + "    v" + String(describing: versionNumber!)
        
        //LocationManager necesary for login
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
 
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        let alertController = UIAlertController.init(title: "Advertencia", message:"Receive memory warning", preferredStyle: .alert)
        
        let aceptar = UIAlertAction.init(title: "Aceptar", style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })

        alertController.addAction(aceptar)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    //MARK: LocationManager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse || status == .denied)
        {
            let alertController = UIAlertController.init(title: "Servicio de Localizacion Inhabilitado", message:"Para iniciar sesion debe habilitar SIEMPRE el Servicio de Localización para este dispositivo.", preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            let configuration = UIAlertAction.init(title: "Configuración", style: .default, handler: { (action: UIAlertAction) in
                UIApplication.shared.openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)! as URL)
            })
            
            alertController.addAction(cancel)
            alertController.addAction(configuration)
            self.present(alertController, animated: true, completion: nil)
            
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    //MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtUsuario)
        {
            txtContrasena.becomeFirstResponder()
        }
        else
        {
            self.login()
        }
        
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
    }
    
    /// Lifts or lowers the view so the keyboard doesn't cover the UITextField
    /// - Parameters:
    ///   - textField: UITextField that you doesn't want the keyboard cover
    ///   - up: Boolean to indicate if lifts or lowers the view
    func animateTextField(textField: UITextField, up: Bool) {
        let movementDistance:CGFloat = -130
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        }
        else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    //MARK: Buttons Action
    
    @IBAction func login() {
        
        self.view.endEditing(true)

        if((txtUsuario.text?.isEmpty)! || (txtContrasena.text?.isEmpty)! )
        {
            let alertController = UIAlertController.init(title: "Error", message:"Usuario o Contraseña incorrectos, favor ingresar nuevamente.", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            MDSession.listStores = Array<MDStore>()
            let loading = MDLoadingView.init(frame: self.view.bounds)
            loading.starLoding(inView: self.view)
            
            MDSession.loginWithUser(username: txtUsuario.text!, password: txtContrasena.text!, location: locationManager.location, hasError: { (hasError: Bool) in
                if(!hasError)
                {
                    // You can call any combination of these three methods
                    Crashlytics.sharedInstance().setUserEmail(self.txtUsuario.text)
                    Crashlytics.sharedInstance().setUserIdentifier(String(MDSession.id))
                    Crashlytics.sharedInstance().setUserName(self.txtUsuario.text)
                    
                    MDSession.getLinkableDevices(hasError: { (hasError: Bool) in
                        if(!hasError)
                        {
                            if(MDSession.listStores.count > 1)
                            {
                                let selectPopUp = MDSelectStorePopUpViewController()
                                selectPopUp.modalPresentationStyle = .overCurrentContext
                                selectPopUp.modalTransitionStyle = .crossDissolve
                                self.present(selectPopUp, animated: true, completion: nil)
                            }
                            else  if(MDSession.listStores.count > 0)
                            {
                                self.userDefault.set(MDSession.listStores[0].salesCode, forKey: "store")
                                self.userDefault.set(self.txtUsuario.text, forKey: "user_name")
                                self.userDefault.set(MDSession.id, forKey: "id")
                                self.userDefault.synchronize()
                                
                                MDSession.sales_code = MDSession.listStores[0].salesCode
                                
                                if(MDSession.listDevices.count > 0)
                                {
                                    let linkUpPopUp = MDLinkUpViewController()
                                    linkUpPopUp.modalPresentationStyle = .overCurrentContext
                                    linkUpPopUp.modalTransitionStyle = .crossDissolve
                                    self.present(linkUpPopUp, animated: true, completion: nil)
                                    
                                }
                                else
                                {
                                    self.navigationController?.pushViewController(MDWelcomeViewController(), animated: true)
                                }
                            }
                            else
                            {
                                if(MDSession.listDevices.count > 0)
                                {
                                    let linkUpPopUp = MDLinkUpViewController()
                                    linkUpPopUp.modalPresentationStyle = .overCurrentContext
                                    linkUpPopUp.modalTransitionStyle = .crossDissolve
                                    self.present(linkUpPopUp, animated: true, completion: nil)
                                    
                                }
                                else
                                {
                                    self.navigationController?.pushViewController(MDWelcomeViewController(), animated: true)
                                }

                            }
                          
                        }
                        
                        loading.stopLoding()
                    })

                }
                else
                {
                    loading.stopLoding()
                }                
            })
        }
      
    }
    
    
    @IBAction func recoverPassword(_ sender: AnyObject) {
        
        let alertController = UIAlertController.init(title: "Recuperar contraseña", message:"Por favor ingrese su email:", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.view.endEditing(true)
            let loading = MDLoadingView.init(frame: self.view.bounds)
            loading.starLoding(inView: self.view)
            MDSession.recoverPass(email: alertController.textFields![0].text!, hasError: { (hasError: Bool) in
                if(!hasError)
                {
                    let alertController = UIAlertController.init(title: "", message:"Un email a sido enviado a tú correo, por favor verificalo", preferredStyle: .alert)
                    let ok = UIAlertAction.init(title: "OK", style: .default, handler:nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)

                }
                 loading.stopLoding()
            })
        
        })
        let cancel = UIAlertAction.init(title: "Cancelar", style: .cancel, handler:  { (action: UIAlertAction) in
           self.view.endEditing(true)
        })

        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.actions[0].isEnabled = false
        self.present(alertController, animated: true, completion: nil)

    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        // enable OK button only if there is text
        // hold my beer and watch this: how to get a reference to the alert
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = (tf.text != "")
    }
    
   
    
    @IBAction func settings(_ sender: Any) {
        
        self.navigationController?.pushViewController(MDSettingsViewController(), animated: false)
    }
    
    deinit {
        print("MDLoginViewController is being deallocated")
    }

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
