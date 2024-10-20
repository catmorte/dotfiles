import argparse
import base64
import json

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from jose import jwe


def main(private_key_string, jwe_string):
    # Prepare the private key
    private_key = f"""-----BEGIN PRIVATE KEY-----\n{private_key_string}\n-----END PRIVATE KEY-----"""

    # Decrypt the JWE
    credential = jwe.decrypt(jwe_string, private_key.encode())
    credential = json.loads(credential.decode())

    # Decode the base64 value
    b64_value = credential.get("value").encode()
    decoded_value = base64.b64decode(b64_value).decode()

    print(decoded_value)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Decrypt a JWE using a private key.")
    parser.add_argument(
        "--private_key_string",
        type=str,
        required=True,
        help="The private key string (without header/footer).",
    )
    parser.add_argument(
        "--jwe_string", type=str, required=True, help="The JWE string to decrypt."
    )

    args = parser.parse_args()
    main(args.private_key_string, args.jwe_string)
