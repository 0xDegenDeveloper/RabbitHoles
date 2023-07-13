import { faArrowUpRightFromSquare } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import styled from "styled-components";

export default function InfoPage() {
  return (
    <>
      <div className="container">
        <Wrapper className="">
          <div className="dark-box-600w box">
            <div className="section-one">
              {/* <h1> > sign in html What is this ?</h1> */}
              <h1>&gt; RabbitHoles</h1>
              <h4>
                - $RBITS are ERC-20 tokens abstracted to create a permanent and
                censorship-resistant discussion board. Users dig holes and burn
                rabbits.
              </h4>
              <h4>- Digging a hole creates a discussion topic.</h4>
              <h4>- Burning a rabbit adds a message to the discussion.</h4>
            </div>
            <div className="section-two">
              <h1>&gt; Technicals</h1>
              <h3 style={{ color: "var(--limeGreen)" }}>::Holes</h3>
              <h4>- Each dig will cost approximately 0.001Ξ.</h4>
              <h4>- Each dig will mint around 25.0 RBITS to the digger.</h4>
              {/* <h5>
              * These values are estimates, the real numbers will be near these
            </h5> */}
              <h4>
                - A hole's title must fit into a single <em>felt252</em> (31
                characters or less).
              </h4>
              <h3 style={{ color: "var(--limeGreen)" }}>::Rabbits</h3>
              <h4>
                - A rabbit's message will fill consecutive slots in a global
                LegacyMap(<em>u64</em> =&gt; <em>felt252</em>).
              </h4>
              <h4>
                - To burn a rabbit, users will need to burn some of their RBITS.
              </h4>
              <h4>
                - For every <em>felt252</em> slot filled by a rabbit's message,
                1.0 RBIT will be burned.
              </h4>
            </div>
            <div className="section-three">
              <h1>
                <em>&gt; Further</em>
              </h1>
              <h4>
                -Additional details and the contract progress can be tracked{" "}
                <a
                  target="_blank"
                  href="https://github.com/0xDegenDeveloper/RabbitHoles"
                >
                  here <FontAwesomeIcon icon={faArrowUpRightFromSquare} />
                </a>
              </h4>
            </div>
          </div>
          <ImgWrapper>
            <div className="token-logo">
              <img src="/logo.png" />
            </div>
          </ImgWrapper>
        </Wrapper>
      </div>
    </>
  );
}

const ImgWrapper = styled.div`
  margin-top: 1rem;
  display: grid;
  place-items: center;

  img {
    width: clamp(50px, 30vw, 100px);

    :hover {
      cursor: pointer;
      animation: rotate360 3s infinite ease-in-out;
    }
  }

  @keyframes rotate360 {
    0% {
      transform: rotate(0deg);
    }
    50%,
    52% {
      transform: rotate(720deg);
    }

    75%,
    100% {
      transform: rotate(0deg);
    }
  }
`;

const Wrapper = styled.div`
  width: clamp(60vw, 40vw, 400px);
  display: grid;
  gap: 0.5rem;
  height: 60%;
  user-select: none;

  .token-logo {
    margin-top: 1rem;
    display: grid;
    place-items: center;

    img {
      width: clamp(50px, 30vw, 100px);

      :hover {
        cursor: pointer;
        animation: rotate360 3s infinite ease-in-out;
      }
    }

    @keyframes rotate360 {
      0% {
        transform: rotate(0deg);
      }
      50%,
      52% {
        transform: rotate(720deg);
      }

      75%,
      100% {
        transform: rotate(0deg);
      }
    }
  }

  h1 {
    font-size: clamp(14px, 2vw, 24px);
    padding: 0.5rem 0 1rem;
  }

  h3 {
    padding: 0;
    margin: 1rem 0;
  }

  h4 {
    margin: 0.5rem 0;
  }
  a {
    color: var(--lightGreen);
    text-decoration: none;
  }

  h4,
  h2 {
    color: var(--limeGreen);
  }

  em {
    color: var(--lightGreen);
  }

  .box {
    /* overflow: scroll;
    border: none; */
  }
`;
