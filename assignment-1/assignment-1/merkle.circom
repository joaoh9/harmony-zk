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


    component hashedLeaf;
    var i;

    for (i=0; i<length; i++) {
        hashedLeaf = HashedLeaf();
        hashedLeaf.k <== merkleList[i];
        tree[i] = hashedLeaf.out;
    }

    component hashedNode;
    
    var iterations = length;

    while (iterations > 1) {
        for ( i=0; i < length/2; i += 2) {
            hashedNode = HashedNode();
            hashedNode.k1 <== tree[i];
            hashedNode.k2 <== tree[i+1];

            tree[i/2] = hashedNode.out;
        }

        iterations = iterations/2;
    }

   // Constraints.
   treeHash <== tree[0];
}

component main = Merkle();