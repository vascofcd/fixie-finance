const tenor = args[0];

// ref: https://markets.newyorkfed.org/static/docs/markets-api.html#/
const codingRequest = Functions.makeHttpRequest({
  url: `https://markets.newyorkfed.org/api/rates/secured/sofr/last/${tenor}.json`,
  method: "GET",
});

const response = await codingRequest;

console.log("Response:", response);

if (!Array.isArray(data?.refRates) || data.refRates.length === 0)
  throw Error("No SOFR data returned for the requested tenor");

if (response.error)
  throw Error("Request failed, try checking the params provided");

const avgSOFR =
  response.data.refRates.reduce((sum, r) => sum + r.percentRate, 0) /
  response.data.refRates.length;

const scaled = avgSOFR * 1000; // e.g. 4.3533 % → 43533

console.log("Scaled SOFR:", scaled);
return Functions.encodeUint256(scaled);
