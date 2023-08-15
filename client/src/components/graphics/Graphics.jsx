import styled from "styled-components";
import Sketch from "react-p5";
import { useLocation } from "react-router-dom";
import { useEffect } from "react";

let bg;

// replace with img objs or add func to return img obs
// let table = {
//   "/": "bg.png",
//   "/stats": "bg-shift.png",
//   "/archive": "bg.png",
//   "/user": "bg-shift.png",
//   "/info": "bg.png",
//   "/digging/": "bg-shift.png",
// };

let bgs = {
  flat: "bg-flat.png",
  flatInverse: "bg-flat-inv.png",
  shiftt: "bg-shift.png",
  shifttInverse: "bg-shift-inv.png",
  shift2: "bg-shift-2.png",
  shift3: "bg-shift-3.png",
};

export default (props) => {
  // useEffect(() => {
  //   console.log("location changed to", props.path);
  // }, [props]);

  const preload = (p5) => {
    // console.log("preload");
    // bg = p5.loadImage(props.path.startsWith("") ? "/bg-shift.png" : "bg.png");
    for (const fn in bgs) {
      const path = `/${bgs[fn]}`;
      bgs[fn] = p5.loadImage(path);
    }
    bg = bgs.shiftt;
  };

  const setup = (p5, canvasParentRef) => {
    p5.createCanvas(window.innerWidth, window.innerHeight).parent(
      canvasParentRef
    );

    window.addEventListener("resize", () => {
      p5.resizeCanvas(window.innerWidth, window.innerHeight);
    });
  };

  // console.log(props.path);

  const draw = (p5) => {
    const whichBg = () => {
      if (props.mobile) {
        return bgs.flatInverse;
      } else {
        return bgs.flat;

        // return bgs.flat;
        if (props.path == "/") {
          return bgs.flat;
        }
        if (props.path.startsWith("/stats")) {
          return bgs.flatInverse;
        }
        if (props.path.startsWith("/archive")) {
          return bgs.shiftt;
        }
        if (props.path.startsWith("/user")) {
          return bgs.shifttInverse;
        }

        if (props.path.startsWith("/info")) {
          return bgs.shiftt;
        } else {
          return bgs.shift3;
        }
      }
    };
    p5.image(whichBg(), 0, 0, p5.width, p5.height);
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
