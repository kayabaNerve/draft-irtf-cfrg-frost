#!/usr/bin/sage
# vim: syntax=python

import sys

from hashlib import sha512, sha256, shake_256

try:
    from sagelib.groups import GroupRistretto255, GroupEd25519, GroupEd448, GroupP256, GroupSecp256k1
except ImportError as e:
    sys.exit("Error loading preprocessed sage files. Try running `make setup && make clean pyfiles`. Full error: " + e)

_as_bytes = lambda x: x if isinstance(x, bytes) else bytes(x, "utf-8")

class Hash(object):
    def __init__(self, G, H, name):
        self.G = G
        self.H = H
        self.name = name

    def H1(self, m):
        raise Exception("Not implemented")

    def H2(self, m):
        raise Exception("Not implemented")

    def H3(self, m):
        raise Exception("Not implemented")

    def H4(self, m):
        raise Exception("Not implemented")

class HashEd25519(Hash):
    def __init__(self):
        Hash.__init__(self, GroupEd25519(), sha512, "SHA-512")

    def H1(self, m):
        hash_input = _as_bytes("rho") + m
        return int.from_bytes(sha512(hash_input).digest(), "little") % self.G.order()

    def H2(self, m):
        return int.from_bytes(sha512(m).digest(), "little") % self.G.order()

    def H3(self, m):
        hasher = self.H()
        hasher.update(m)
        return hasher.digest()

    def H4(self, m):
        hash_input = _as_bytes("nonce") + m
        return int.from_bytes(sha512(hash_input).digest(), "little") % self.G.order()

class HashEd448(Hash):
    def __init__(self):
        Hash.__init__(self, GroupEd448(), shake_256, "SHAKE256")

    def H1(self, m):
        hash_input = _as_bytes("rho") + m
        return int.from_bytes(shake_256(hash_input).digest(int(114)), "little") % self.G.order()

    def H2(self, m):
        return int.from_bytes(shake_256(m).digest(int(114)), "little") % self.G.order()

    def H3(self, m):
        hasher = self.H()
        hasher.update(m)
        return hasher.digest(int(114))

    def H4(self, m):
        hash_input = _as_bytes("nonce") + m
        return int.from_bytes(shake_256(hash_input).digest(int(114)), "little") % self.G.order()

class HashRistretto255(Hash):
    def __init__(self):
        Hash.__init__(self, GroupRistretto255(), sha512, "SHA-512")

    def H1(self, m):
        hash_input = _as_bytes("FROST-RISTRETTO255-SHA512-v5rho") + m
        return int.from_bytes(sha512(hash_input).digest(), "little") % self.G.order()

    def H2(self, m):
        hash_input = _as_bytes("FROST-RISTRETTO255-SHA512-v5chal") + m
        return int.from_bytes(sha512(hash_input).digest(), "little") % self.G.order()

    def H3(self, m):
        hasher = self.H()
        hasher.update(_as_bytes("FROST-RISTRETTO255-SHA512-v5digest"))
        hasher.update(m)
        return hasher.digest()

    def H4(self, m):
        hash_input = _as_bytes("FROST-RISTRETTO255-SHA512-v5nonce") + m
        return int.from_bytes(sha512(hash_input).digest(), "little") % self.G.order()

class HashP256(Hash):
    def __init__(self):
        Hash.__init__(self, GroupP256(), sha256, "SHA-256")

    def H1(self, m):
        dst = _as_bytes("FROST-P256-SHA256-v5rho")
        return self.G.hash_to_scalar(m, dst=dst)

    def H2(self, m):
        dst = _as_bytes("FROST-P256-SHA256-v5chal")
        return self.G.hash_to_scalar(m, dst=dst)

    def H3(self, m):
        hasher = self.H()
        hasher.update(_as_bytes("FROST-P256-SHA256-v5digest"))
        hasher.update(m)
        return hasher.digest()

    def H4(self, m):
        dst = _as_bytes("FROST-P256-SHA256nonce")
        return self.G.hash_to_scalar(m, dst=dst)

class HashSecp256k1(Hash):
    def __init__(self):
        Hash.__init__(self, GroupSecp256k1(), sha256, "SHA-256")

    def H1(self, m):
        dst = _as_bytes("FROST-secp256k1-SHA256-v7rho")
        return self.G.hash_to_scalar(m, dst=dst)

    def H2(self, m):
        dst = _as_bytes("FROST-secp256k1-SHA256-v7chal")
        return self.G.hash_to_scalar(m, dst=dst)

    def H3(self, m):
        hasher = self.H()
        hasher.update(_as_bytes("FROST-secp256k1-SHA256-v7digest"))
        hasher.update(m)
        return hasher.digest()

    def H4(self, m):
        dst = _as_bytes("FROST-secp256k1-SHA256nonce")
        return self.G.hash_to_scalar(m, dst=dst)
