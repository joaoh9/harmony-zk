pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/

include "./mimcsponge.circom";

template HashedLeaf() {
    signal input k;
    signal output out;

    component hash = MiMCSponge(1, 220, 1);
    hash.ins[0] <== k;
    hash.k <== 0;

    out <== hash.outs[0];
}

template HashedNode() {
    signal input k1;
    signal input k2;
    signal output out;

    component hash = MiMCSponge(2, 220, 1);
    hash.ins[0] <== k1;
    hash.ins[1] <== k2;
    hash.k <== 0;

    out <== hash.outs[0];
}

template Merkle () {

   // Declaration of signals.
    var length = 4;
    signal input merkleList[length];

    signal output treeHash;

    var tree[length];

    component hashedLeaf[length];
    var i;

    for (i=0; i<length; i++) {
        hashedLeaf[i] = HashedLeaf();
        hashedLeaf[i].k <== merkleList[i];
        tree[i] = hashedLeaf[i].out;
    }

    component hashedNode[length];
    
    var iterations = length;
    // iterations = 4

    while (iterations > 1) {
        i = 0;
        while (i < length / 2){
            hashedNode[i] = HashedNode();
            hashedNode[i].k1 <== tree[i];
            hashedNode[i].k2 <== tree[i+1];

            tree[i/2] = hashedNode[i].out;
            // tree[0] = hashedNode[0] + hashedNode[1]
            // tree[1] = hashedNode[2] + hashedNode[3]
            i = i + 2;
        }

        iterations = iterations/2;
        // interactions = 2
    }

   // Constraints.
   treeHash <== tree[0];
}

component main = Merkle();