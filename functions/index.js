// FirestoreとCloud Functionsは、各々異なるサーバー上で動作している。
// Firestore：NoSQL型のdbで、データの保存と取得を担当一方
// Cloud Functions：サーバーレスのコンピューティングサービスで、特定のイベント（Firestoreのデータ変更時など）に反応して関数を実行

const functions = require("firebase-functions");
// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.

const {initializeApp} = require("firebase-admin/app");
const {getFirestore: getFirestoreRef} = require("firebase-admin/firestore");
// The Firebase Admin SDK to access Firestore.
// firestoreの参照を取得する関数のimport

initializeApp(); //
// initializeApp()関数が呼び出され
// Firebase Admin SDKの初期化がされた時に
// Firestoreのインスタンスが作成され
// メモリにロード（格納）される

exports.runTransaction = functions.https.onCall(async (data, context) => {
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

