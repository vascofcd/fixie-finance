async function main() {
  const tenor = args[0];

  let scaled = await getSOFRRate(tenor);

  return Functions.encodeUint256(scaled);
}

async function getSOFRRate(tenor) {
  const request = Functions.makeHttpRequest({
    url: `https://markets.newyorkfed.org/api/rates/secured/sofr/last/${tenor}.json`,
  });

  const [response] = await Promise.all([request]);
  if (response.status !== 200) {
    return null;
  }
  const avgSOFR =
    response.data.refRates.reduce((sum, r) => sum + r.percentRate, 0) /
    response.data.refRates.length;

  return Math.round(avgSOFR * 1000);
}

const result = await main();

return result;
