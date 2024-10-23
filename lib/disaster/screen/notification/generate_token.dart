import 'package:firebase_admin/firebase_admin.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

void main() async {
  final serviceAccount = auth.ServiceAccountCredentials.fromJson(
    {
      "type": "service_account",
      "project_id": "disastermain-66982",
      "private_key_id": "81d6de0abe970ddf16b5fce1f6aec58bf751994a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCom3gRsZkdqe2r\ny3U3hfl/xfYMFIccNVqUpMGpQ8Ag342p8WEozCAG9u+S2V2cNQcYlcwMWEgfUuYt\n0hMb5mrQgv9UGURr4AOkOqEtUpTkRB5L304xCoRK74QGCQuYoBCQ8WVoclDw15wC\nktZFvU81lC/WAECOn//3e2seuGfoj8hxGb2fpzOPX6kYkeLCkyPRAtcNlou5N++E\nf2ZlGc9HeQcek7qZ2D7vDWCDjYZVr6J3NuIvnHJn827eZcOQrn+4NMPHHu0YhW1b\nJowgiP8qP6xIKmfK1zFl4bdSbHJBrE5WUiRkwcBqXizKUULYKMyucfd413k77YJz\niS4AMOQ3AgMBAAECggEATZF82zMH/MAtIiCPtDQUNUbXK/aTtBQNsJ3dpKgRL255\np4nvh4vlXh7j1/zdVpyEv7hGsBU7VQHX+JORi//k+zmRCtk3A6QDON5qQUYhTqTS\nBVjeCazLcQghBn/J0HUvOed8nmEdQLgIw5xXLK1rz/v1R/BEwvj0EyC6Bt+Smkgw\nVBQuFPNDU2Kzki/u54btlweEKnxu8Gc+VQh19Ts9Wsw8Iepz6F1lN1GEu+oNZKOu\npoY578QVvsEQra3OX2tg69OegStuuCflMIUe6oNSRRgY+eC3t0v4fH3rcnJsy14U\nmYkmtJ6vm/bJV0rcV10BUOhb43UqAIerXcV0x52SJQKBgQDcMhCsCi+ME6Skm8om\nc3FR5LtVgy9Cc/8CAPsmuBByaMCNbiMeOkitGTK6EeBKupPeiJ9XGPqUQRhtpVIX\nOMZ4tfdM6rofclOmjr6FydaPUDzZmIJ8ndY0+GtFCfYRNYnWf03z13D/xog8Zb/m\nGGTdTkUfP5GmlZK4E7wEzcIhZQKBgQDEBfktSbxO2OUaLHh077GB/dQqik8pEQC2\nfczCfKIpT0b+M/CBCwux8Pef1r1Q4LgZPsRNdVz/0rsZ9WoOu22sRmUYpBebQYO4\n0+JRQWvkujKF+yU7j84DhIY6Gu+oo4nOD/dCrWyQ81KX3Q3OQFm0tsMh5j/27u+v\nW3FjatnDawKBgGqa7olsUQK/S9nJ9v/Qqk9crvnCjnHc2Nwuf2mKeaP6ZSbT6Lqs\nuxza8z00hGOJmyeE+6feVwrJzTrgbDMD8MrmRjl99uhcoHUl7MW3J2KxFRTACoSs\nodV5Y+3D2dcRFY+8iJACgRnEE5cyJ8sNil++kiaDz09YYPUv0Lp+p3slAoGBAJ+3\nFj22NH4x7wmSblso6YK25GX8517YgbIvceSNVDtAYuHARBeAfnjvk3NirkH1t0qq\nf5t1It82Pkh6U33JbSTO/pRDLxDLIp431dDK8zQcGgpchQuwsfTfx9YUGG1ZQnDp\nRVfIogrAlu0xqYwBlpXNy9QVHM0ABb7lTM/qQaAdAoGBAKgw6jwNAvJK4zb93w5P\nykSw8BciIxywpBtAoJeJ+gglO2E0wYaIRO/enyqoi+FABTtLfJuvAXAd36pdMqCG\nCms8HZjzeJuNLZPc2frtBluVk9DB0VMQ1SaUz9cdJmrvuxdgYLevmKbyIsi+RYM9\naGRoVWfpieHF7dbR7Y85HTte\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-tafqy@disastermain-66982.iam.gserviceaccount.com",
      "client_id": "108003546609362808142",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-tafqy%40disastermain-66982.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    },
  );

  final scopes = [
    'https://www.googleapis.com/auth/cloud-platform',
  ];

  final client = await auth.clientViaServiceAccount(serviceAccount, scopes);
  final token = await client.credentials.accessToken;
  print('Access Token: ${token.data}');
}
