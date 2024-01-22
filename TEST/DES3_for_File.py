from Crypto.Cipher import DES3
from Crypto.Hash import SHA256 as SHA
from os import path;
import sys;

KSIZE = 1024

class myDES():
    def __init__(self, keytext, ivtext):
        hash = SHA.new()
        hash.update(keytext.encode("utf-8"))
        key = hash.digest()
        self.key = key[:24]

        hash.update(ivtext.encode('utf-8'))
        iv = hash.digest()
        self.iv = iv[:8]

    def makeEncInfo(self, filename):
        fillersize = 0
        filesize = path.getsize(filename)
        if filesize % 8 != 0:
            fillersize = 8 - filesize % 8
        filler = '0' * fillersize
        header = "%d" % (fillersize)
        gap = 8 - len(header)
        header += "#" * gap

        return header, filler

    def enc(self, filename):
        encfilename = filename + '.enc'
        header, filler = self.makeEncInfo(filename)
        des3 = DES3.new(self.key, DES3.MODE_CBC, self.iv)

        with open(filename, 'rb') as h, open(encfilename, "wb+") as hh:
            enc = header.encode('utf-8')
            content = h.read(KSIZE)
            content = enc + content
            while content:
                if len(content) < KSIZE:
                    content += filler.encode('utf-8')
                enc = des3.encrypt(content)
                hh.write(enc)
                content = h.read(KSIZE)
                
    def dec(self, encfilename):
        filename = encfilename + '.dec'
        des3 = DES3.new(self.key, DES3.MODE_CBC, self.iv)
    
        with open(encfilename, 'rb') as hh, open(filename, 'wb+') as h:
            content = hh.read(8)
            dec = des3.decrypt(content)
            try:
                header = dec.decode('utf-8')
                fillersize = int(header.split("#")[0])
            except UnicodeDecodeError:
                fillersize = 0
    
            content = hh.read(KSIZE)
            while content:
                dec = des3.decrypt(content)
                if len(dec) < KSIZE:
                    if fillersize != 0:
                        dec = dec[:-fillersize]
                h.write(dec)
                content = hh.read(KSIZE)


def main(mode, filename, keytext='samsjang', ivtext='1234'):
    myCipher = myDES(keytext, ivtext)
    if mode == 'enc':
        myCipher.enc(filename)
    elif mode == 'dec':
        encfilename = filename + '.enc'
        myCipher.dec(encfilename)

if __name__ == "__main__":
    print(sys.argv)
    if len(sys.argv) != 5:
        print("Usage: python DES3_for_File.py mode filename keytext ivtext")
        sys.exit(1)
    

    mode = sys.argv[1]
    filename = sys.argv[2]
    keytext = sys.argv[3] 
    ivtext = sys.argv[4]
    main(mode, filename, keytext, ivtext)

