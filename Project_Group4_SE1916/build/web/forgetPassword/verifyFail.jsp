<%-- 
    Document   : verifyFail
    Created on : May 24, 2025, 10:19:31 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Fail</title>
    <style>
        body {
            background: linear-gradient(135deg, #ffebee, #f1f1f1);
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
            max-width: 450px;
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
            color: #c0392b;
            padding: 20px 0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .payment-item.message {
            font-size: 1.1rem;
            color: #34495e;
            padding: 30px 0;
            line-height: 1.5;
        }
        .payment-item-one-list {
            display: flex;
            justify-content: center;
            gap: 20px;
            padding: 0;
            margin: 0;
            list-style: none;
        }
        .payment-item-one-list-item {
            display: inline;
        }
        .payment-item-one-list-item a button {
            height: 2.5em;
            width: 9em;
            font-size: 1.1rem;
            font-weight: bold;
            color: #fff;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        .payment-item-one-list-item a button.retry {
            background: linear-gradient(90deg, #32c671, #27ae60);
        }
        .payment-item-one-list-item a button.cancel {
            background: linear-gradient(90deg, #da4453, #c0392b);
        }
        .payment-item-one-list-item a button:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
        }
        .payment-item-one-list-item a button.retry:hover {
            background: linear-gradient(90deg, #27ae60, #219653);
        }
        .payment-item-one-list-item a button.cancel:hover {
            background: linear-gradient(90deg, #c0392b, #a93226);
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
            .payment-item.message {
                font-size: 1rem;
            }
            .payment-item-one-list {
                flex-direction: column;
                gap: 15px;
            }
            .payment-item-one-list-item a button {
                width: 8em;
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="payment-successful">
        <div class="payment-successful-content">
<!--            <div class="payment-item">
                <img src="../Assets/icon/icon (79).png" alt="Failure Icon">
            </div>-->
            <div class="payment-item title">Xác nhận tài khoản thất bại!</div>
            <div class="payment-item message">
                Mã xác nhận không đúng, ấn "Thử lại" để nhận mã xác nhận mới!
            </div>
            <div class="payment-item-one">
                <ul class="payment-item-one-list">
                    <li class="payment-item-one-list-item">
                        <a href="./forget_password">
                            <button class="retry" type="button">Thử lại</button>
                        </a>
                    </li>
                    <li class="payment-item-one-list-item">
                        <a href="../login.jsp">
                            <button class="cancel" type="button">Hủy bỏ</button>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>