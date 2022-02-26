const Ballot = artifacts.require('Ballot');

module.exports = function (deployer) {
  deployer.deploy(
    Ballot,
    [1, 2, 3],
    '0x0000000000000000000000000000000000000000',
    1,
    '0x0000000000000000000000000000000000000000'
  );
};
