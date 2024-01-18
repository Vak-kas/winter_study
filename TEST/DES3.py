from Crypto.Cipher import DES3
from Crypto.Hash import SHA256 as SHA
import sys

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
        plaintext = make8String(plaintext)
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

def main():
    if len(sys.argv) != 4:
        print("사용법: DES3.py <keytext> <ivtext> <msg>")
        sys.exit(1)

    keytext = sys.argv[1]
    ivtext = sys.argv[2]
    msg = sys.argv[3]

    myCipher = myDES(keytext, ivtext)
    ciphered = myCipher.enc(msg)
    deciphered = myCipher.dec(ciphered)

    print("Original : \t%s" % msg)
    print("Ciphered : \t%s" % ciphered)
    print("Deciphered : \t%s" % deciphered)
main()

# 결과 데이터를 파일로 저장



