render = (name) -> """
<body>
  <main><section>
    <h1>Hello, #{name}!</h1>
    <p>
      Congratulations! Seeing this page indicates a successful deployment of your test API with Panda Sky!
    </p>
    <p>
      Sky thinks of APIs as contracts designed to serve resources, and they can include webpages themselves.  For example, this page is served through an endpoint configured with the type <code>text/html</code>.  For now, Sky only supports JSON-based resources and text/html.  But, serverless technology is agnostic to how you assemble the resources and the Lambda compute units that back this API can do whatever you need.
    </p>
    <p>
      So, go forth and create!  And if you're interested in Panda Sky, you can read more about it <a href="https://www.pandastrike.com/open-source/panda-sky">here</a>.  If you'd like to read more about the inspiration for Sky's approach to APIs, <a href="https://www.pandastrike.com/posts/20151019-create-more-web"> look here</a>.
    </p>
  </section></main>
  <footer>
    <p> &copy; 2017, Panda Strike, LLC, All Rights Reserved Worldwide </p>
  </footer>
</body>
</html>
"""

export default render
