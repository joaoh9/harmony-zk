require('chai').use(require('chai-as-promised')).should();
const { expect } = require('chai');
const Ballot = artifacts.require('Ballot');
const E721 = artifacts.require('E721');

contract('Ballot tests', accounts => {
  beforeEach(async () => {
    i = await Ballot.new(
      [1, 2, 3],
      '0x0000000000000000000000000000000000000000'
    );
  });

  function BNtoStr(bn) {
    return bn.toString();
  }

  it.only('update erc721 token whitelist', async () => {
    await i.updateERC721ToWhitelist('0x0000000000000000000000000000000000000001', {
      from: accounts[1],
    }).should.be.rejected;

    await i.updateERC721ToWhitelist('0x0000000000000000000000000000000000000001');

    const newERC721 = await i.erc721whitelist();

    expect(newERC721).to.equal('0x0000000000000000000000000000000000000001');
  });

  it.only('update erc721 token whitelist', async () => {
    const e721 = await E721.new({ from: accounts[2] });
    const balanceOf = await e721.balanceOf(accounts[2]);
    expect(balanceOf.toString()).to.equal('1');

    await i.updateERC721ToWhitelist(e721.address);

    const newERC721 = await i.erc721whitelist();
    expect(newERC721).to.equal(e721.address);

    await i.vote(2, { from: accounts[2] });
  });
});
