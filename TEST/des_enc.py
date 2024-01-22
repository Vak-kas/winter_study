from Crypto.Cipher import DES3
from Crypto.Hash import SHA256 as SHA
import sys

class myDES():
from Crypto.Cipher import DES3
from Crypto.Hash import SHA256 as SHA

class myDES():
    def __init__(self, keytext, ivtext):
        hash = SHA.new()
        hash.update(keytext.encode('utf-8'))
        key = hash.digest()
        self.key = key[:24]

        hash.update(ivtext.encode('utf-8'))
        iv = hash.digest()
        self.iv = iv[:8]
        
    def enc(self, plaintext):
        des3 = DES3.new(self.key, DES3.MODE_CBC, self.iv)
        encmsg = des3.encrypt(plaintext.encode())
        return encmsg

    def dec(self, ciphertext):
        des3 = DES3.new(self.key, DES3.MODE_CBC, self.iv)
        decmsg = des3.decrypt(ciphertext)
        return decmsg
    
    def make8String(msg):
        msglen = len(msg)
        filler = ''
        if msglen%8 !=0:
            filler = '0'*(8-msglen%8)
        msg +=filler
        return msg

def main(data, keytext, ivtext):
    myCipher = myDES(keytext, ivtext)
    ciphered = myCipher.enc(msg)
    deciphered = myCipher.dec(ciphered)

    return ciphered




if __name__ == "__main__":
#     print("helloword")
#     print(sys.argv)
    if len(sys.argv) != 4:
        print("Usage: python DES3.py mode data keytext ivtext")
        sys.exit(1)

    data = sys.argv[2]
    keytext = sys.argv[3] 
    ivtext = sys.argv[4]
    main(data, keytext, ivtext)
