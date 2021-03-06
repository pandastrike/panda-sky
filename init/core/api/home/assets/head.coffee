render = (name) -> """
<!DOCTYPE html>
<html>
<head>
  <style>
    @import url('//fonts.googleapis.com/css?family=Lora');
    @import url('//fonts.googleapis.com/css?family=Titillium+Web');
    @import url('//fonts.googleapis.com/css?family=Cabin');
    body {
      padding: 1rem;
      padding-top: 4rem;
      font-size: 6.5px;
      font-family: 'Lora';
      color: #444;
      display: flex;
      flex-flow: row wrap;
      justify-content: space-evenly;
    }
    h1,
    h2,
    h3,
    h4,
    h5,
    label,
    figcaption {
      font-family: 'Cabin';
      letter-spacing: 1.2;
    }
    h1 {
      line-height: 5rem;
      font-size: 4.5rem;
    }
    h2 {
      line-height: 4rem;
      font-size: 3.6rem;
    }
    header {
      margin-left: 1rem;
      margin-right: 2rem;
    }
    header img {
      height: 8rem;
    }
    main {
      display: flex;
      flex-flow: column nowrap;
      flex: grow 1 1 0;
      align-items: center;
      overflow: scroll;
      min-width: 0;
      min-height: 85vh;
    }
    aside {
      font-family: 'Titillium Web';
    }
    footer {
      flex: 1 1 100vw;
      border-top: 1px solid #c0c0c0;
      font-family: 'Titillium Web';
    }
    footer p {
      line-height: 1rem;
      font-size: 0.9rem;
    }
    section {
      padding: 1rem;
      line-height: 2rem;
      font-size: 1.4rem;
      max-width: 60ch;
      min-width: 20ch;
      width: 100%;
    }
    section h1:first-child {
      margin-top: 0;
    }
    section li {
      padding-bottom: 1rem;
    }
    pre {
      margin: 1rem;
      line-height: 1rem;
      font-size: 0.9rem;
    }
    a {
      color: inherit;
    }
  </style>
  <title>#{if name then name + " - " || ""}Panda Sky Demo</title>
</head>
"""

export default render
