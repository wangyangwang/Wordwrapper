

Pair<ArrayList<String>, Float> wrappedWords;

void setup() {
  pixelDensity(2);
  size(800, 800);

  String s = " vitae, justo. Nulean vulputa";
  int maxW = 300;
  int maxLine = 40;
  wrappedWords = wordWrap(s, maxW, maxLine);
}

void draw() {
  background(160);
  float[] anchorPoints = new float[4];
  anchorPoints = drawStringHelper(wrappedWords, 20, 1,  width/2, height/2, 0.5, 0.5, LEFT, true ).a;
  strokeWeight(2);
  point(anchorPoints[0], anchorPoints[1]);
  point(anchorPoints[2], anchorPoints[3]);
  text(frameRate, 10,10);
}

//drawStringHelper: returns array of {left(x0),top(y0),right(x1),bottom(y1)}, lines
//actuallyDraw: pass false to just calc bounds
Pair<float[], ArrayList<String>> drawStringHelper(
  Pair<ArrayList<String>,Float> myPair,
  float textSize, 
  float lineSpacing, 
  float xLeft, 
  float yTop, 
  float pivotUX, 
  float pivotUY, 
  int align, 
  boolean actuallyDraw)
{
  //pivotUX, pivotUY: kinda like the UV for the anchor point.
  //pivot(0,0) = top-left aligned, from the top
  //pivot(1,0) = right-aligned, from the top
  //pivot(0.5, 0) = centered, from the top
  //pivot(0.5, 0.5) = centered vertically and horizontally
  //... etc.

  float size = textSize;
  //size = 140;
  textSize(size);


  float lineHeight = size * lineSpacing;

  ArrayList<String> a = myPair.a;
  float actualTextWidth = myPair.b;
  float actualTextHeight = a.size() * lineHeight + textDescent();

  float x = xLeft - pivotUX * actualTextWidth;
  float y = yTop - pivotUY * actualTextHeight;
  float ret[] = new float[4];
  ret[0] = x;
  ret[1] = y;
  ret[2] = x + actualTextWidth;
  ret[3] = y + actualTextHeight;

  if (actuallyDraw)
  {
    for (int i=0; i<a.size(); i++) 
    {
      switch (align) {
      case LEFT:
        textAlign(LEFT);
        text(a.get(i), x, y + size + i * lineHeight);
        break;
      case RIGHT:
        textAlign(RIGHT);
        text(a.get(i), x + actualTextWidth, y + size + i * lineHeight);
        break;
      case CENTER:
        textAlign(CENTER);
        text(a.get(i), x + actualTextWidth/2, y + size + i * lineHeight);
        break;
      }
    }
  }

  return new Pair<float[], ArrayList<String>>(ret, a);
}

public class Pair<A, B> {
  public A a;
  public B b;
  public Pair(A setA, B setB) { 
    a = setA; 
    b = setB;
  }
}

Pair<ArrayList<String>, Float> wordWrap(String s, int maxWidth, int maxLines) 
{
  // Make an empty ArrayList
  ArrayList<String> a = new ArrayList<String>();
  float retw = 0;

  float w = 0;    // Accumulate width of chars
  int i = 0;      // Count through chars
  int rememberSpace = -1; // Remember where the last space was, Default is "not found"

  int paranoia = -1;
  int paranoia2 = -1;
  // As long as we are not at the end of the String
  while (i < s.length()) 
  {
    paranoia2++;
    if (paranoia2 > 2048)
    {
      //System.err.println("Paranoia2 exceeded, tried to draw > 2048 iterations!");
      break;
    }
    // Current char
    char c = s.charAt(i);
    w += textWidth(c); // accumulate width
    if (c == ' ') 
    {
      rememberSpace = i; // Are we a blank space?
    }

    if (w > maxWidth) 
    {  // Have we reached the end of a line?
      int initialRS = rememberSpace;
      int skipSpaces = 0; //needed for non-space breaking, otherwise we'll get duplicated chars, defaults to zero for spaces.
      if (rememberSpace < 0) //consume N-1 characters, where N is i (N is too many by the one latest character)
      {
        skipSpaces = 1;//don't duplicate the char!
        rememberSpace = i - 1;
        if (rememberSpace < 0) //always consume at least one character
        {
          rememberSpace = 0;
        }
      }

      {
        String sub = s.substring(0, rememberSpace+skipSpaces); // Make a substring
        /*
        // Chop off space at beginning
         if (sub.length() > 0 && sub.charAt(0) == ' ') //doesn't include a trailing(breaking) space at the beginning of the current line
         {
         sub = sub.substring(1,sub.length());
         }
         */
        sub = sub.trim(); //chop off leading & trailing spaces

        retw = Math.max(retw, textWidth(sub)); //calculate widest line

        // Add substring to the list
        a.add(sub);

        // Reset everything
        s = s.substring(rememberSpace+skipSpaces, s.length());
        s = s.trim(); //hack, deal with spaces
        System.out.println("i = "+i+", w = "+w+", initialRS = "+initialRS+", rememberSpace = "+rememberSpace+", sub = '"+sub+"', s(prime)='"+s+"'");
        i = 0;
        w = 0;
        rememberSpace = -1;
      }

      paranoia++;
      if (paranoia > maxLines-1) //forcibly escape after max lines
      {
        System.err.println("Paranoia exceeded! escaping!");
        break;
      }
    } else 
    {
      i++;  // Keep going!
    }
  }

  // Take care of the last remaining line
  if (s.length() > 0 && s.charAt(0) == ' ') 
  {
    s = s.substring(1, s.length());
  }
  a.add(s);
  retw = Math.max(retw, textWidth(s)); //calculate widest line
  retw = Math.min(retw, maxWidth);
  return new Pair<ArrayList<String>, Float>(a, retw);
}