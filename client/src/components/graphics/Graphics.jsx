import styled from "styled-components";
import Sketch from "react-p5";

let bg;

export default (props) => {
  const preload = (p5) => {
    bg = p5.loadImage("/bg.png");
  };

  const setup = (p5, canvasParentRef) => {
    p5.createCanvas(window.innerWidth, window.innerHeight).parent(
      canvasParentRef
    );

    window.addEventListener("resize", () => {
      p5.resizeCanvas(window.innerWidth, window.innerHeight);
    });
  };

  const draw = (p5) => {
    p5.image(bg, 0, 0, p5.width, p5.height);
  };

  return (
    <StyledSketch
      preload={preload}
      setup={setup}
      draw={draw}
      style={{ zIndex: 1 }}
    />
  );
};

const StyledSketch = styled(Sketch)`
  position: absolute;
  top: 0;
  z-index: 1;
`;
