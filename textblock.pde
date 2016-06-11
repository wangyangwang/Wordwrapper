
void setup() {
  size(900, 900);
  ArrayList<String> a = new ArrayList<String>();
  String mystring = "Li Europan";// lingues es membres del sam familie. ";
  int maxw = 900 - 30;
  int size;
  size = 140;
  int left = 256;
  int top = 0;

  float lineSpacing = 1.3f; //one and a half lines (approx)
  Pair<float[], ArrayList<String>> textInfo = drawStringHelper(mystring, size, lineSpacing, maxw, left, top, 0.5f, 0, true);
  float x0 = textInfo.a[0];//left
  float y0 = textInfo.a[1];//top
  float x1 = textInfo.a[2];//bottom
  float y1 = textInfo.a[3];//right

  strokeWeight(10);
  stroke(255, 0, 0);
  line(left, 0, left, height);//centerline for rendering

  line(x0, 0, x1, 0);//horizontal range
  line(0, y0, 0, y1);//vertical range
}

//drawStringHelper: returns array of {left(x0),top(y0),right(x1),bottom(y1)}, lines
//actuallyDraw: pass false to just calc bounds
Pair<float[], ArrayList<String>> drawStringHelper(String str, int textSize, float lineSpacing, int maxWidth, int xLeft, int yTop, float pivotUX, float pivotUY, boolean actuallyDraw)
{
  //pivotUX, pivotUY: kinda like the UV for the anchor point.
  //pivot(0,0) = top-left aligned, from the top
  //pivot(1,0) = right-aligned, from the top
  //pivot(0.5, 0) = centered, from the top
  //pivot(0.5, 0.5) = centered vertically and horizontally
  //... etc.

  int maxLines = 64;

  int size = textSize;
  //size = 140;
  textSize(size);

  float lineHeight = size * lineSpacing;

  Pair<ArrayList<String>, Float> myPair;
  myPair = wordWrap(str, maxWidth, maxLines);
  //Note: final line might be too wide to fit, if we exceeded the limit!

  ArrayList<String> a = myPair.a;
  float actualTextWidth = myPair.b;
  float actualTextHeight = a.size() * lineHeight;

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
      text(a.get(i), x, y + size + i * lineHeight);
    }
  }

  return new Pair<float[], ArrayList<String>>(ret, a);
}

public class Pair<A, B> {
  public A a;
  public B b;
  public Pair(A setA, B setB) { 
    a =setA; 
    b=setB;
  }
}

// Function to return an ArrayList of Strings
// (maybe redo to just make simple array?)
// Arguments: String to be wrapped, maximum width in pixels of line
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
      System.err.println("Paranoia2 exceeded, tried to draw > 2048 iterations!");
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