import { Link } from 'react-router-dom';
import Button from '../components/LandingPage/Button';

const LandingPage = () => {
  return (
    <section className="relative w-full h-screen overflow-hidden">
      {/* Background Image Container */}
      <div className="absolute inset-0">
        <img 
          src="/images/desktop-homebg.svg" 
          alt="Background"
          className="w-full h-full object-cover object-bottom"
        />
      </div>
      
      {/* Terms Links */}
      <div className="absolute top-5 right-15 flex gap-x-8 z-10 font-semibold text-white">
        <Link className='font-orbitron' to="">[ Terms and Conditions ]</Link>
        <Link className='font-orbitron' to="">[ Privacy Policy ]</Link>
      </div>

      {/* Main Content */}
      <div className='relative z-10 w-full h-full flex flex-col items-center justify-center gap-8'>
        <img src="/images/logo.svg" className='w-[300px] h-auto' alt="Velvet Ace Logo" />
        
        <h1 className='font-orbitron'>
          Velvet Ace
        </h1>

        {/* Buttons Container */}
        <div className='flex gap-4 mt-8'>
          <Button variant='gradient' radius='md'>Connect Wallet to Play</Button>
          <Button variant='outline-yellow'>How to Play</Button>
        </div>
      </div>
    </section>
  )
}

export default LandingPage;