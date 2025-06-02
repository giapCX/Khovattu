
<%-- 
    Document   : verifySuccessful
    Created on : May 24, 2025, 10:19:48 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verify Successful</title>
        <style>
            body {
                background: linear-gradient(135deg, #e0f7fa, #f1f1f1);
                font-family: 'Arial', sans-serif;
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }
            .payment-successful-content {
                text-align: center;
                width: 55%;
                max-width: 400px;
                background: #fff;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                animation: fadeIn 1s ease-in-out;
            }
            .payment-item img {
                width: 20%;
                max-width: 80px;
                transition: transform 0.3s ease;
            }
            .payment-item img:hover {
                transform: scale(1.1);
            }
            .payment-item.title {
                font-weight: bold;
                font-size: 2.2rem;
                color: #2c3e50;
                padding: 20px 0;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .payment-item.button-container {
                padding-top: 40px;
            }
            .payment-item a button {
                height: 2.5em;
                width: 12em;
                font-size: 1.2rem;
                font-weight: bold;
                color: #fff;
                background: linear-gradient(90deg, #32c671, #27ae60);
                border: none;
                border-radius: 12px;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }
            .payment-item a button:hover {
                background: linear-gradient(90deg, #27ae60, #219653);
                transform: translateY(-3px);
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
            }
            .payment-item.title {
                color: #32c671;
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            @media (max-width: 600px) {
                .payment-successful-content {
                    width: 80%;
                    padding: 20px;
                }
                .payment-item.title {
                    font-size: 1.8rem;
                }
                .payment-item a button {
                    width: 10em;
                    font-size: 1rem;
                }
            }
        </style>
    </head>
    <body>
        <div class="payment-successful">
            <div class="payment-successful-content">
                <!--            <div class="payment-item">
                                <img src="../Assets/icon/icon (74).png" alt="Success Icon">
                            </div>-->
                <div class="payment-item title">Account verification successful!</div>
                <div class="payment-item button-container">
                    <a href="./changePasswordByForget">
                        <button type="button">Change Password</button>
                    </a>
                </div>
            </div>
        </div>
    </body>
</html>


