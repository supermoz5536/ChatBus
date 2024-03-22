// FirestoreとCloud Functionsは、各々異なるサーバー上で動作している。
// Firestore：NoSQL型のdbで、データの保存と取得を担当
// Cloud Functions：サーバーレスのコンピューティングサービスで、特定のイベント（Firestoreのデータ変更時など）に反応して関数を実行
const axios = require("axios");
// Axiosライブラリをインポート（HTTPリクエストを行うために使用）
const geoip = require("geoip-lite");
// IPアドレスから国名を推測するライブラリ
const functions = require("firebase-functions");
// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const Stripe = require("stripe");
// 決済ページの用意とリダイレクトを行うStripeのライブラリ

const {initializeApp} = require("firebase-admin/app");
const {getFirestore: getFirestoreRef} = require("firebase-admin/firestore");
// The Firebase Admin SDK to access Firestore.
// firestoreの参照を取得する関数のimport

initializeApp(); //
// initializeApp()関数が呼び出され
// Firebase Admin SDKの初期化がされた時に
// Firestoreのインスタンスが作成され
// メモリにロード（格納）される

exports.createCheckoutSession = functions.runWith({
  memory: "512MB", // メモリの割り当てを増やす
}).https.onCall(async (data) => {
  try {
  // Stripeオブジェクトを新規作成し、Stripe APIを利用するためのシークレットキーとAPIのバージョンを指定します。
    const stripe = new Stripe(
        process.env.STRIPE_API_KEY,
        {apiVersion: "2023-10-16"},
    );
    // Stripeの顧客を新規作成し、その結果をcustomer変数に格納します。
    const customer = await stripe.customers.create();
    // StripeのCheckoutセッションを新規作成し、その設定を行います。
    const session = await stripe.checkout.sessions.create({
      // 作成した顧客のIDをセッションに紐付けます。
      customer: customer.id,
      // 支払い方法として「カード」と「顧客の残高」を指定します。
      payment_method_types: ["card"],
      // 支払い方法のオプションを指定します。
      payment_method_options: {
        // 顧客の残高に関する設定を行います。
        customer_balance: {
          // 資金の種類として「銀行振込」を指定します。
          funding_type: "bank_transfer",
          // 銀行振込に関する設定を行います。
          bank_transfer: {
            // 日本の銀行振込を指定します。
            type: "jp_bank_transfer",
          },
        },
      },
      // 請求項目の設定を開始します。
      line_items: [{
        // Stripeで事前に設定したプライスIDを指定します。
        price: "price_1Owjhu02YGIp0FEBowcQVeQy",
        // 購入数量を1に設定します。
        quantity: 1,
      }],
      // このセッションのモードを「支払い」に設定します。
      mode: "subscription",
      // 支払いが成功した際にリダイレクトするURLを指定します。
      success_url: "https://udemy-882f1.web.app/",
      // 支払いがキャンセルされた際にリダイレクトするURLを指定します。
      cancel_url: "https://udemy-882f1.web.app/",
    });
    return session.id;
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

exports.getCountryFromIP = functions.runWith({
  memory: "512MB", // メモリの割り当てを増やす
}).https.onCall((data, context) => {
  try {
    const ip = data.ip; // Flutterアプリから受け取るIPアドレス
    const geo = geoip.lookup(ip);

    if (geo) {
      return {country: geo.country};
    // country というキーを持つオブジェクトを作成
    // その値として geo.country（国コード）を設定
    }
  } catch (e) {
    throw new functions.https.HttpsError(
        "Error: getCountryFromIP",
        `IPアドレスから国名の取得失敗: ${e}`);
  }
});

// DeepL APIを呼び出すためのFirebase Functionを定義
exports.translateDeepL = functions.runWith({
  memory: "512MB", // メモリの割り当てを増やす
}).https.onCall(async (data, context) => {
  // ロギング
  console.log(`API呼び出し: テキスト="${data.text}", 言語="${data.target_lang}"`);
  // DeepL APIのエンドポイントURL
  const endpoint = "https://api-free.deepl.com/v2/translate";
  // あなたのDeepL APIキーを設定
  const apiKey = process.env.DEEPL_API_KEY;

  // DeepL APIに送信するパラメータを設定
  const params = new URLSearchParams();
  params.append("auth_key", apiKey); // 認証用のAPIキー
  params.append("text", data.text); // 翻訳するテキスト
  params.append("target_lang", data.target_lang); // 目的の言語
  if (["DE", "FR", "IT", "ES", "NL", "PL", "PT-BR", "PT-PT", "JA", "RU"]
      .includes(data.target_lang)) {
    params.append("formality", "less"); // カジュアルな翻訳スタイルを指定
  }
  // DeepL APIへのPOSTリクエストを実行し、結果を取得
  try {
    const response = await axios.post(endpoint, params);
    return response.data; // 翻訳結果を返却
  } catch (error) {
    // エラー発生時にはFirebaseのエラーをスロー
    throw new functions.https.HttpsError("internal", error.message);
  }
});

exports.runTransaction = functions.runWith({
  memory: "512MB", // メモリの割り当てを増やす
}).https.onCall(async (data, context) => {
// onCallはクライアントから直接呼び出し可能関数の作成するメソッド
// 引数dataは、クライアントから渡されるデータ内容 myUid talkuserUid myRoomId
// 引数contextは、実行する関数の情報(関数名とか)とクライアント自身の情報（IPアドレスとか）

  const db = getFirestoreRef();
  // メモリに格納されたfirestoreインスタンスからの参照を取得してるので同期的（即時取得）、awaitいらない
  // 確認：data.myUidが有効

  if (!data.myUid) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with 'myUid' argument.",
    );
  }

  try {
    return db.runTransaction(async (transaction) => {
      // 引数のtransactionオブジェクトを媒体として
      // Firestoreデータベース上の、
      // 一連の読み取りと書き込み操作を
      // 一つの作業単位として扱う

      const myFieldsRef = db.collection("user").doc(data.myUid);
      // const myFieldsSnapshot = await transaction.get(myFieldsRef);
      // const myFieldsData = myFieldsSnapshot.data();

      const talkuserFieldsRef = db.collection("user").doc(data.talkuserUid);
      const talkuserFieldsSnapshot = await transaction.get(talkuserFieldsRef);
      const talkuserFieldsData = talkuserFieldsSnapshot.data();

      if (talkuserFieldsData.progress_marker === true) {
        throw new functions.https.HttpsError(
            `エラー:トランザクション相手が現在マッチング処理中 retry`,
        );
      } else if (talkuserFieldsData.matched_status === true) {
        throw new functions.https.HttpsError(
            `エラー:トランザクション相手がlock解除後に既にマッチング済み retry`,
        );
        // DocumentCへのlock待機後の再readで既にマッチング済みだった場合は
        // 実行中のトランザクションを失敗させる
      } else {
        transaction.update(myFieldsRef, {
          "matched_status": true,
          "room_id": data.myRoomId,
        });
        transaction.update(talkuserFieldsRef, {
          "matched_status": true,
          "room_id": data.myRoomId,
        });
      }
    });
  } catch (e) {
    throw new functions.https.HttpsError(
        "server method error",
        `サーバーサイドトランザクションエラー発生: ${e}`);
  }
});

