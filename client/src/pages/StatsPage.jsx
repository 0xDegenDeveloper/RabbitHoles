import fetchGlobalStats from "../components/hooks/fetchGlobalStats";

export default function StatsPage() {
  const { holes, rabbits, depth, totalSupply, digFee, digReward } =
    fetchGlobalStats();
  return (
    <>
      <div className="container">
        <div
          className="dark-box-600w"
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
            gap: "0",
          }}
        >
          <h1 style={{ color: "var(--limeGreen)" }}>Metrics</h1>
          <h4>
            Supply: <em>{totalSupply} $RBITS</em>
          </h4>
          <h4>
            Dig Fee: <em>{digFee}Ξ</em>
            {" > "}Dig Reward: <em>{digReward} $RBITS</em>
          </h4>
          <h1 style={{ color: "var(--limeGreen)" }}>Stats</h1>
          <h4>
            Holes: <em>{holes}</em>
            {" > "}Rabbits: <em>{rabbits}</em>
            {" > "}Depth: <em>{depth}</em>
          </h4>
        </div>
      </div>
    </>
  );
}
