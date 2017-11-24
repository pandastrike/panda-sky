render = (name) -> """
<body>
  <main><section>
    <h1>Hello, #{name}!</h1>
    <p>
      Seeing this page indicates a successful deployment of your test API with Panda Sky!
    </p>
    <p>
      Think of APIs as contracts designed to serve resources.  Those resources should always <a href="https://www.pandastrike.com/posts/20151019-create-more-web"> "Create More Web" <a/>, and they can include webpages themselves.
    </p>
    <p>
      Panda Sky respects that principle through the use of mediatypes.  For example, this page is served through an endpoint configured with the type <code>text/html</code>.  For now, this is written in HTML primatives, but the technology is agnostic to how you assemble the resources and the Lambda compute units that back this API can do whatever you need.
    </p>
    <p>
      So, go forth and create!  And if you're interested in Panda Sky, you can read more about it <a href="https://www.pandastrike.com/open-source/panda-sky">here</a>.
    </p>
  </section></main>
  <footer>
    <p> &copy; 2017, Panda Strike, LLC, All Rights Reserved Worldwide </p>
  </footer>
</body>
</html>
"""

export default render
