//
//  LoginPanelView.swift
//  AITherapist
//
//  Created by cyrus refahi on 12/22/23.
//

import SwiftUI

struct LoginPanelView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var isEmailFocused: Bool = false
    @State private var isPasswordFocused: Bool = false
    
    let onGoogleLoginClicked: () -> ()
    let onFacebookLoginClicked: () -> ()
    let onLoginClicked: () -> ()

    var body: some View {
        VStack{
            Spacer()
            
            Text("Welcome Back")
            
            Spacer()
            
            LoginInputView
            
            Spacer()
                .frame(maxHeight: 50)
            
            loginBtnView
            
            Spacer()
            //                .frame(maxHeight: 50)
            
            thirdPartyLoginBtnView
            
            Spacer()
            
            newToAvaView
        }.onTapGesture {
            self.hideKeyboard()
        }
        
        .background(background)
    }
    
    @ViewBuilder var background: some View {
        AuthenticationBackgroundView()
    }
    
    @ViewBuilder var loginBtnView: some View{
        Button(action: {
            onLoginClicked()
        }, label: {
            Text("Login")
                .font(
                    Font.custom("SF Pro Text", size: 16)
                        .weight(.semibold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPallet.TextYellow)
        })
        .padding(.horizontal, 50)
        .padding(.vertical, 5)
        .frame(height: 54, alignment: .center)
        .background(ColorPallet.DarkGreen)
        .cornerRadius(50)
    }
    
    @ViewBuilder var LoginInputView: some View{
        VStack(alignment: .center, spacing: 15) {
            TextField("Email Adress", text: $email)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .frame(width: 276, alignment: .leading)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: nil, height: 1, alignment: .bottom)
                        .foregroundColor(ColorPallet.DarkGreen)
                        .shadow(color: ColorPallet.DarkGreen, radius: 1, x: 0, y: 1), alignment: .bottom
                )
        }
        .padding(0)
        
        VStack(alignment: .center, spacing: 15) {
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .frame(width: 276, alignment: .leading)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).frame(width: nil, height: 1, alignment: .bottom).foregroundColor(ColorPallet.DarkGreen).shadow(color: ColorPallet.DarkGreen, radius: 1, x: 0, y: 1), alignment: .bottom)

        }
        .padding(0)
    }
    
    @ViewBuilder var thirdPartyLoginBtnView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Image("GoogleIcon")
                    .frame(width: 33, height: 34)
                // Regular/Footnote
                Text("Continue with Google")
                    .font(Font.custom("SF Pro Text", size: 13))
                    .foregroundColor(ColorPallet.DarkGreen)
                    .padding(.horizontal, 0)
                    .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .frame(width: 296, alignment: .leading)
            .background(ColorPallet.LoginThirdPartyButtonColor)
            .cornerRadius(5)
            
            HStack(alignment: .center, spacing: 0) {
                Image("FacebookIcon")
                    .frame(width: 33, height: 34)
                
                // Regular/Footnote
                Text("Continue with Facebook")
                    .font(Font.custom("SF Pro Text", size: 13))
                    .foregroundColor(ColorPallet.DarkGreen)
                    .padding(.horizontal, 0)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .frame(width: 296, alignment: .leading)
            .background(ColorPallet.LoginThirdPartyButtonColor)
            .cornerRadius(5)
        }
        .padding(0)
    }
    
    @ViewBuilder var newToAvaView: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("New to Ava?")
                .font(Font.custom("SF Pro Text", size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPallet.DarkGreen)
            
            Text("Sign up for free")
                .font(Font.custom("SF Pro Display", size: 15))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPallet.DarkGreen)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(0)
    }
    
}

#Preview {
    LoginPanelView(email: Binding.constant(""), password: Binding.constant(""), onGoogleLoginClicked: {}, onFacebookLoginClicked: {}, onLoginClicked: {})
}
